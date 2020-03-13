# Hyperspeed

## For writing Hypertext at speed in Ruby

Unlike other Ruby interfaces for generating HTML, `hyperspeed` works with a simple Hash abstract syntax tree until the very last moment, allowing you to write helpers and objects that transform and compose your HTML partials. `hyperspeed` also provides a terse and lightweight Ruby DSL for writing your HTML (whether partials, components, or fragments).


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'hyperspeed'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install hyperspeed

## Usage

If you've ever been frustrated by ERB or HAML's inability to easily compose or transform your partials/components, then `hyperspeed` is likely for you. Or, if you've simply wanted to write your markup in pure Ruby with the simplest possible methods, `hyperspeed` is here to help.

The `Hyperspeed` module provides only two methods: `define` and `render`. You may pass a block to either, in which you write HTML as if it were pure Ruby:

```ruby
Hyperspeed.render do
  form([
    input({ type: 'text' }),
    button({ type: 'submit' }, 'Greet'),
    output
  ])
end

# => "<form><input type=\"text\"></input><button type=\"submit\">Greet</button><output></output></form>"
```

The `Hyperspeed.define` method accepts a block and will return a Hash AST representing your markup:

```ruby
Hyperspeed.define do
  form([
    input({ type: 'text' }),
    button({ type: 'submit' }, 'Greet'),
    output
  ])
end

# => {
#  type: :ELEMENT,
#  tag: :form,
#  children: [
#    {
#      type: :ELEMENT,
#      tag: :input,
#      properties: { type: "text" }
#    },
#    {
#      type: :ELEMENT,
#      tag: :button,
#      properties: { type: "submit" },
#      children: [
#        {
#          type: :TEXT,
#          value: "Greet"
#        }
#      ]
#    },
#    {
#      type: :ELEMENT,
#      tag: :output
#    }
#  ]
# }
```

The `Hyperspeed.render` method accepts either a block or such a Hash. If it receives a block, it will delegate that block to `Hyperspeed.define`, receive the AST Hash back, and then render that AST Hash to a string. If it receives an AST Hash directly, it will simply return your markup as a string.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/hyperspeed.
