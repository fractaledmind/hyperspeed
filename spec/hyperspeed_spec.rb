# frozen_string_literal: true

# rubocop:disable Metrics/BlockLength
RSpec.describe Hyperspeed do
  it 'has a version number' do
    expect(Hyperspeed::VERSION).not_to be nil
  end

  describe '.render' do
    it 'with a block returns HTML string' do
      html_string = Hyperspeed.render do
        form([
          input(type: 'text'),
          button({ type: 'submit' }, 'Greet')
        ])
      end

      expect(html_string).to eql '<form><input type="text"></input><button type="submit">Greet</button></form>'
    end

    it 'handles attribute value as array of strings' do
      html_string = Hyperspeed.render { div(class: ['c1', 'c2']) }

      expect(html_string).to eql '<div class="c1 c2"></div>'
    end

    it 'handles attribute value as mixed array' do
      html_string = Hyperspeed.render { div(class: ['c1', :c2]) }

      expect(html_string).to eql '<div class="c1 c2"></div>'
    end

    it 'handles attribute value as array with duplicate strings' do
      html_string = Hyperspeed.render { div(class: ['c1', 'c1']) }

      expect(html_string).to eql '<div class="c1"></div>'
    end

    it 'handles attribute value as array with mixed duplicates' do
      html_string = Hyperspeed.render { div(class: ['c1', :c1]) }

      expect(html_string).to eql '<div class="c1"></div>'
    end
  end

  describe '.define' do
    it 'with a block returns AST hash' do
      ast_hash = Hyperspeed.define do
        form([
          input(type: 'text'),
          button({ type: 'submit' }, 'Greet')
        ])
      end

      expect(ast_hash).to eql(type: :ELEMENT, tag: :form, children: [
                                { type: :ELEMENT, tag: :input, properties: { type: 'text' } },
                                { type: :ELEMENT, tag: :button, properties: { type: 'submit' }, children: [
                                  { type: :TEXT, value: 'Greet' }
                                ] }
                              ])
    end
  end
end
# rubocop:enable Metrics/BlockLength
