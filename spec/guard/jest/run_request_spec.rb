require_relative '../../spec_helper'
require 'ostruct'
require 'irb'


RSpec.describe Guard::Jest::Runner do
    let(:server)  { Guard::Jest::Server.new(Guard::Jest::DEFAULT_OPTIONS) }
    let(:options) { Guard::Jest::DEFAULT_OPTIONS.merge(server: server) }
    let(:runner)  { Guard::Jest::Runner.new(options) }
    let(:paths)   { %w(one two three) }
    let(:request) { Guard::Jest::RunRequest.new(runner, paths) }

    describe '#initialize' do
        it 'remembers runner and paths option' do
            expect(request.paths).to  eq(paths)
            expect(request.runner).to eq(runner)
        end

        context('when paths == :all') do
            let(:paths){ :all }
            it 'returns true from all?' do
                expect(request.paths).to eq(:all)
                expect(request.all?).to eq(true)
            end
        end
    end


    describe '#satisfy' do

        it 'notifys runner' do
            expect(runner).to receive(:notify).with(request)
            request.satisfy(run_result_fixture(:success))
        end

        it 'sets satisfied? to true' do
            request.satisfy(run_result_fixture(:success))
            expect(request.satisfied?).to eq(true)
        end

        it 'remembers result' do
            request.satisfy(run_result_fixture(:success))
            expect(request.result).to eq( run_result_fixture(:success) )
        end
    end
end
