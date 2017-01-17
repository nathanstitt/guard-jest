require_relative '../../spec_helper'
require 'ostruct'
require 'irb'

RSpec.describe Guard::Jest::Runner do
    let(:server)  { Guard::Jest::Server.new(Guard::Jest::DEFAULT_OPTIONS) }
    let(:options) { Guard::Jest::DEFAULT_OPTIONS.merge(server: server) }
    let(:runner)  { Guard::Jest::Runner.new(options) }

    before(:each) do
        allow(server).to receive(:busy?).and_return false
        allow(server).to receive(:alive?).and_return true
    end

    describe '#initialize' do
        it 'remembers server option' do
            expect(runner.server).to eq(server)
        end
    end

    describe '#test_all' do
        it 'calls server#run_all' do
            expect(server).to receive(:run_all)
            runner.test_all
        end
    end

    describe '#test_paths' do
        it 'calls server#run_paths' do
            paths = ['/bar/baz', '/foo/bar']
            expect(server).to receive(:run_paths).with(paths)
            runner.test_paths(paths)
        end
    end

    describe '#reload' do
        it 'resets failed specs' do
            runner.last_failed_paths.concat([1])
            expect { runner.reload(options) }.to change(runner, :last_failed_paths).from([1]).to([])
        end
    end

    describe '#run_on_modifications' do
        it 're-runs previously failed' do
            runner.options[:keep_failed] = true
            runner.last_failed_paths = [:a_failure]
            expect(server).to receive(:run_paths).with([:new_spec, :a_failure])
            runner.test_paths([:new_spec])
        end

        it 'removes duplicate and nil paths' do
            runner.options[:keep_failed] = true
            runner.last_failed_paths = [:a, :b, :c]
            expect(server).to receive(:run_paths).with([:a, :b, :c])
            runner.test_paths([:a, nil, :b])
        end
    end

    describe '#remove_paths' do
        it 'removes them from failed paths' do
            runner.last_failed_paths = [:a, :b, :c]
            expect { runner.remove_paths([:b, :c]) }.to(
                change(runner, :last_failed_paths).from([:a, :b, :c]).to([:a])
            )
        end
    end

    describe '#notify' do
        let(:request) { Guard::Jest::RunRequest.new(runner, :all) }

        it 'notifys server of successful run' do
            expect(Guard::Jest::Formatter).to receive(:success).with(/2 specs, 0 failures/)
            expect(Guard::Jest::Formatter).to(
                receive(:notify).with(/2 specs, 0 failures/, title: "Jest suite passed")
            )
            expect(Guard::Jest::Formatter).to receive(:info).with(/Finished/)

            request.satisfy(run_result_fixture(:success))
        end

        it 'notifies when runs fail' do
            expect(Guard::Jest::Formatter).to receive(:info).with(/Finished/)

            expect(Guard::Jest::Formatter).to(
                receive(:error).with(/Link changes the class when hovered/)
            )
            expect(Guard::Jest::Formatter).to(
                receive(:notify).with(
                    /CheckboxWithLabel changes the text after click/,
                    title: 'Jest test run failed', image: :failed, priority: 2
                )
            )
            request.satisfy(run_result_fixture(:failure))
        end
    end
end
