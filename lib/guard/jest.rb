require 'logger'
require 'guard/compat/plugin'

require_relative 'jest/version'
require_relative 'jest/formatter'
require_relative 'jest/run_request'
require_relative 'jest/runner'
require_relative 'jest/server'

module Guard
    # The Jest guard that gets notifications about the following
    # Guard events: `start`, `stop`, `reload`, `run_all` and `run_on_modifications`.
    class Jest < Plugin
        class << self
            attr_writer :logger
            def logger
                @logger ||= ( l = Logger.new(STDOUT); l.level = Logger::INFO; l )
            end
        end

        DEFAULT_OPTIONS = {
            jest_cmd: 'jest'
        }.freeze

        attr_reader :runner, :server

        # Initialize Guard::Jest
        #
        # @param [Hash] options the options for the Guard
        # @option options [String] :config_file the location of a Jest configuration file
        # @option options [String] :jest_cmd path to jest application that should be executed
        #
        def initialize(options = {})
            options = DEFAULT_OPTIONS.merge(options)
            @runner = options[:runner] || Runner.new(options)
            @server = options[:server] || Server.new(options)
            super(options)
        end

        # Called once when Guard starts. Please override initialize method to init stuff.
        #
        # @raise [:task_has_failed] when start has failed
        # @return [Object] the task result
        #
        def start
            throw :task_has_failed unless server.start
            run_all if options[:all_on_start]
        end

        # Called when `stop|quit|exit|s|q|e + enter` is pressed (when Guard quits).
        #
        # @raise [:task_has_failed] when stop has failed
        # @return [Object] the task result
        #
        def stop
            throw :task_has_failed unless server.stop
        end

        # Called when `reload|r|z + enter` is pressed.
        # This method should be mainly used for "reload" (really!) actions like reloading passenger/spork/bundler/...
        #
        # @raise [:task_has_failed] when reload has failed
        # @return [Object] the task result
        #
        def reload
            server_success = server.reload(options)
            runner_success = runner.reload(options)
            throw :task_has_failed unless server_success && runner_success
        end

        # Called when just `enter` is pressed
        # This method should be principally used for long action like running all specs/tests/...
        #
        # @raise [:task_has_failed] when run_all has failed
        # @return [Object] the task result
        #
        def run_all
            results = runner.test_all
            throw :task_has_failed if results.failed?
        end

        # Called on file(s) additions that the Guard plugin watches.
        #
        # @param [Array<String>] paths the changes files or paths
        # @raise [:task_has_failed] when run_on_additions has failed
        # @return [Object] the task result
        #
        def run_on_additions(paths)
            run_on_modifications(paths)
        end

        # Called on file(s) modifications that the Guard plugin watches.
        #
        # @param [Array<String>] paths the changes files or paths
        # @raise [:task_has_failed] when run_on_modifications has failed
        # @return [Object] the task result
        #
        def run_on_modifications(paths)
            results = runner.test_paths(paths)
            throw :task_has_failed if results.failed?
        end

        # Called on file(s) removals that the Guard plugin watches.
        #
        # @param [Array<String>] paths the changes files or paths
        # @raise [:task_has_failed] when run_on_removals has failed
        # @return [Object] the task result
        #
        def run_on_removals(paths)
            runner.remove_paths(paths)
        end
    end
end
