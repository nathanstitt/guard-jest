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
                server.run(RunRequest.new(self, :all))
            end

            def test_paths(paths)
                paths = paths.concat(last_failed_paths) if options[:keep_failed]

                server.run(RunRequest.new(self, paths.uniq.compact))
            end

            def remove_paths(paths)
                self.last_failed_paths -= paths
            end

            def notify(request)
                @last_result = r = request.result

                specs         = r['numTotalTests'] - r['numPendingTests']
                failed        = r['numFailedTests']
                specs_plural  = specs == 1 ? '' : 's'
                failed_plural = failed == 1 ? '' : 's'

                Formatter.info("Finished in #{request.elapsed_seconds} seconds")

                pending = r['numPendingTests'] > 0 ? " #{r['numPendingTests']} pending," : ''
                message = "#{specs} spec#{specs_plural}," \
                          "#{pending} #{failed} failure#{failed_plural}"
                full_message = "#{message}\nin #{request.elapsed_seconds} seconds"

                if failed.zero?
                    Formatter.success(message)
                    Formatter.notify(full_message, title: 'Jest suite passed')
                else
                    Formatter.error(
                        collect_spec_error_messages(r['testResults']).join("\n")
                    )
                    error_title = collect_spec_error_titles(r['testResults']).join("\n")
                    Formatter.notify("#{error_title}\n#{full_message}",
                                     title: 'Jest test run failed', image: :failed, priority: 2)
                end
            end

            def collect_spec_error_titles(specs)
                specs.select { |s| s['status'] == 'failed' }.map do |s|
                    result = s['assertionResults'].detect { |res| res['status'] == 'failed' }
                    result ? result['title'] : 'Unknown failure'
                end
            end

            def collect_spec_error_messages(specs)
                specs.select { |s| s['status'] == 'failed' }.map do |s|
                    s['message']
                end
            end
        end
    end
end
