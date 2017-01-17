require 'guard/ui'
require 'guard/compat/plugin'

module Guard
    class Jest < Plugin

        class Runner
            attr_reader :server, :options

            attr_accessor :last_failed_paths, :last_result

            def initialize(options)
                reload(options)
            end

            def reload(options)
                @options = options
                @server = options[:server]
                self.last_failed_paths = []
            end

            def test_all
                server.run(RunRequest.new(:all))
            end

            def test_paths(paths)
                paths = paths.concat(last_failed_paths) if options[:keep_failed]
                server.run(RunRequest.new(paths.uniq.compact))
            end

            def remove_paths(paths)
                self.last_failed_paths -= paths
            end
        end
    end
end
