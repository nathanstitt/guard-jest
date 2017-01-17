require 'rspec'
require 'pathname'
require 'guard/compat/test/helper'
require_relative '../lib/guard/jest'

module FixtureHelpers
    def run_result_fixture(name)
        JSON.parse(
            Pathname.new(__FILE__).dirname.join('fixtures', "run-#{name}.json").read
        )
    end
end

RSpec.configure do |config|
    config.mock_with :rspec do |mocks|
        mocks.syntax = :expect
        mocks.verify_partial_doubles = true
    end
    config.include FixtureHelpers
end
