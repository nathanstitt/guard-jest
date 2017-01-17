require_relative '../spec_helper'
require 'ostruct'
require 'irb'

RSpec.describe Guard::Jest do
    let(:options) { Guard::Jest::DEFAULT_OPTIONS }
    let(:server)  { Guard::Jest::Server.new(options) }
    let(:runner)  { Guard::Jest::Runner.new(options) }
    let(:jest)    { Guard::Jest.new(server: server, runner: runner) }
    let(:successfull_result) { OpenStruct.new(:'failed?' => false) }
    let(:failure_result)     { OpenStruct.new(:'failed?' => true) }
    describe '.logger' do
        after(:each) { Guard::Jest.instance_variable_set(:@logger, nil) }

        it 'initializes a default one' do
            expect(Guard::Jest.logger).to be_an(Logger)
            expect(Guard::Jest.logger.level).to eq(Logger::INFO)
        end

        it 'can be set to a custom value' do
            Guard::Jest.logger = StringIO.new
            expect(Guard::Jest.logger).to be_an(StringIO)
        end
    end

    describe '#initialize' do
        context 'when no options are provided' do
            it 'sets default options' do
                expect(jest.runner).to be_an(Guard::Jest::Runner)
            end
        end

        context 'with other options than the default ones' do
            let(:jest) do
                Guard::Jest.new(jest_cmd: 'test')
            end
            it 'uses the provided options' do
                expect(jest.options[:jest_cmd]).to eql 'test'
            end
        end
    end

    describe '#start' do
        it 'raises exception if server start fails' do
            expect(server).to receive(:start).and_return false
            expect { jest.start }.to raise_error(/task_has_failed/)
        end
    end

    describe '#stop' do
        it 'raises exception if server stop fails' do
            expect(server).to receive(:stop).and_return false
            expect { jest.stop }.to raise_error(/task_has_failed/)
        end
    end

    describe '#reload' do
        it 'reloads the server and runner' do
            expect(server).to receive(:reload).and_return false
            expect(runner).to receive(:reload).and_return false
            expect { jest.reload }.to raise_error(/task_has_failed/)
        end
    end

    describe '#run_all' do
        it 'raises exception if there are failures' do
            expect(runner).to receive(:test_all).and_return failure_result
            expect { jest.run_all }.to raise_error(/task_has_failed/)
        end

        it 'succeeds if no failures' do
            expect(runner).to receive(:test_all).and_return successfull_result
            expect { jest.run_all }.to_not raise_error
        end
    end

    describe '#run_on_additions' do
        it 'treats them as new specs' do
            expect(jest).to receive(:run_on_modifications)
            expect { jest.run_on_additions([:foo]) }.to_not raise_error
        end
    end

    describe '#run_on_modifications' do

    end

    describe '#run_on_removals' do
        it 'notifies runner' do
            expect(runner).to receive(:remove_paths).with([:a, :b])
            jest.run_on_removals([:a, :b])
        end
    end
end
