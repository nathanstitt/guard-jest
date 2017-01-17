require 'concurrent/atomic/atomic_boolean'

module Guard
    class Jest < Plugin
        class RunRequest

            attr_reader :paths, :result

            def initialize(paths = :all)
                @paths = paths
                @end_time = Time.now
                @start_time = Time.now
                @is_complete = Concurrent::AtomicBoolean.new(false)
            end

            def all?
                :all == paths
            end

            def elapsed_seconds
                if satisfied?
                    @end_time - @start_time
                else
                    Time.now - @start_time
                end
            end

            def satisfied?
                @is_complete.true?
            end

            def satisfy(json)
                @end_time = Time.now
                @is_complete.make_true
                @result = json
                notify(json)
            end

            def notify(json)
                r = json

                specs         = r['numTotalTests'] - r['numPendingTests']
                failed        = r['numFailedTests']
                specs_plural  = specs == 1 ? '' : 's'
                failed_plural = failed == 1 ? '' : 's'

                Formatter.info("Finished in #{elapsed_seconds} seconds")

                pending = r['numPendingTests'] > 0 ? " #{r['numPendingTests']} pending," : ''
                message = "#{specs} spec#{specs_plural}," \
                          "#{pending} #{failed} failure#{failed_plural}"
                full_message = "#{message}\nin #{elapsed_seconds} seconds"

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
