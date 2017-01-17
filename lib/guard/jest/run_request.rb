require 'concurrent/atomic/atomic_boolean'

module Guard
    class Jest < Plugin
        class RunRequest

            attr_reader :paths, :runner, :result

            def initialize(runner, paths)
                @runner = runner
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
                runner.notify(self)
            end
        end
    end
end
