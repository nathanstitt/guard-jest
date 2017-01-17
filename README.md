[![Build Status](https://travis-ci.org/nathanstitt/guard-jest.svg?branch=master)](https://travis-ci.org/nathanstitt/guard-jest)

# Guard::Jest automatically tests your Jest specs when files are modified.

It runs the Jest server in watch mode, so that it can run specs more efficiently when instructed.

## Installation

Add this line to your application's Gemfile:

Add Guard::Jest to your `Gemfile`:

```ruby
group :development, :test do
  gem 'guard-jest'
end
```

Add the default Guard::Jest template to your `Guardfile` by running:

```bash
$ guard init jest
```
## Usage

Please read the [Guard usage documentation](https://github.com/guard/guard#readme).

## Guardfile

Guard::Jest can be adapted to all kind of projects. Please read the
[Guard documentation](https://github.com/guard/guard#readme) for more information about the Guardfile DSL.

```ruby
guard 'jest' do
  watch(%r{spec/javascripts/spec\.(js\.coffee|js|coffee)$})         { "spec/javascripts" }
  watch(%r{spec/javascripts/.+_spec\.(js\.coffee|js|coffee)$})
  watch(%r{app/assets/javascripts/(.+?)\.(js\.coffee|js|coffee)$})  { |m| "spec/javascripts/#{m[1]}_spec.#{m[2]}" }
end
```

## Options

There are many options that can customize Guard::Jest to your needs. Options are simply supplied as hash when
defining the Guard in your `Guardfile`:

```ruby
guard 'jest', jest_cmd: './node_modules/jest-cli/bin/jest.js' do
  ...
end
```

### Server options

The server options configures the server environment that is needed to run Guard::Jest:

```ruby
directory:    <cwd>                           # Directory that should be used for running Jest
config_file:  nil                             # Path to a [Jest configuration file](https://facebook.github.io/jest/docs/configuration.html)

jest_cmd:     jest                            # Command to execute in order to start the Jest server
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/nathanstitt/guard-jest.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
