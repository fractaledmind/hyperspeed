# frozen_string_literal: true

require_relative './hyperspeed/version'

# rubocop:disable Style/CommentedKeyword
module Hyperspeed
  class Error < StandardError; end

  def self.define(&block)
    definition_proxy = DefinitionProxy.new
    definition_proxy.evaluate(&block)
  end

  # rubocop:disable Metrics/AbcSize
  def self.render(ast = nil) # &block
    ast ||= define(&Proc.new)

    if ast[:type] == :ELEMENT
      tag_name = ast[:tag].to_s.downcase
      # ensure the string we are reducing isn't frozen, so that we can modify it
      content = ast[:children]&.reduce(+'') { |memo, child| memo << render(child) }

      if ast[:properties]
        properties = dasherize_nested_hash_keys(ast[:properties])
                     .map { |k, v| %(#{k}="#{Array[v].join(' ')}") }
                     .join(' ')
        %(<#{tag_name} #{properties}>#{content}</#{tag_name}>)
      else
        %(<#{tag_name}>#{content}</#{tag_name}>)
      end
    elsif ast[:type] == :TEXT
      ast[:value].to_s
    else
      fail 'Root `type` must be either ELEMENT or TEXT!'
    end
  end
  # rubocop:enable Metrics/AbcSize

  class DefinitionProxy
    def evaluate(&block)
      @self_before_instance_eval = eval('self', block.binding, __FILE__, __LINE__)
      instance_eval(&block)
    end

    # rubocop:disable Style/MethodMissingSuper
    def method_missing(tag_or_method, *args)
      if @self_before_instance_eval.respond_to?(tag_or_method, _include_private_methods = true)
        @self_before_instance_eval.send(tag_or_method, *args)
      else
        build_ast(tag_or_method, *args)
      end
    end
    # rubocop:enable Style/MethodMissingSuper

    def respond_to_missing?(_tag_or_method, *_args)
      true
    end

    # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity, Metrics/AbcSize
    def build_ast(tag, properties_or_children_or_text = nil, children_or_text = nil)
      definition = {
        type: :ELEMENT,
        tag: tag
      }
      if properties_or_children_or_text && children_or_text
        if children_or_text.is_a?(Array)
          unless properties_or_children_or_text.is_a?(Hash)
            fail Error, 'when `children` are defined as second argument, first argument must be a `properties` Hash'
          end

          definition.merge(properties: properties_or_children_or_text,
                           children: children_or_text)
        elsif children_or_text.is_a?(String)
          unless properties_or_children_or_text.is_a?(Hash)
            fail Error, 'when `text` is defined as second argument, first argument must be a `properties` Hash'
          end

          definition.merge(properties: properties_or_children_or_text,
                           children: [{
                             type: :TEXT,
                             value: children_or_text
                           }])
        else
          # rubocop:disable Layout/LineLength
          fail Error, 'when first argument is a `properties` Hash, second argument must be either `Array` of `children` or a `String`'
          # rubocop:enable Layout/LineLength
        end
      elsif properties_or_children_or_text.is_a?(Hash)
        definition.merge(properties: properties_or_children_or_text)
      elsif properties_or_children_or_text.is_a?(Array)
        definition.merge(children: properties_or_children_or_text)
      elsif properties_or_children_or_text.is_a?(String)
        definition.merge(children: [{
                           type: :TEXT,
                           value: properties_or_children_or_text
                         }])
      elsif properties_or_children_or_text.nil?
        definition
      else
        fail Error, 'first argument must be a `properties` Hash, `children` Array, text `String`, or empty'
      end
    end
    # rubocop:enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity, Metrics/AbcSize
  end
end

def dasherize_nested_hash_keys(hash)
  separator = '-'
  hash.each_with_object({}) do |(key, value), output|
    if value.is_a? Hash
      dasherize_nested_hash_keys(value).each do |subkey, subvalue|
        flat_key = [key, subkey].join(separator)
        output[flat_key] = subvalue
      end
    elsif key.is_a? Array
      flat_key = key.join(separator)
      output[flat_key] = value
    else
      output[key] = value
    end
  end
end
# rubocop:enable Style/CommentedKeyword
