require_relative '../../spec_helper'
require 'ostruct'
require 'irb'


RSpec.describe Guard::Jest::Runner do
    let(:server)  { Guard::Jest::Server.new(Guard::Jest::DEFAULT_OPTIONS) }
    let(:options) { Guard::Jest::DEFAULT_OPTIONS.merge(server: server) }
    let(:runner)  { Guard::Jest::Runner.new(options) }
    let(:paths)   { %w(one two three) }
    let(:request) { Guard::Jest::RunRequest.new(paths) }

    describe '#initialize' do
        it 'remembers paths option' do
            expect(request.paths).to  eq(paths)
        end

        context('when paths == :all') do
            let(:paths) { :all }
            it 'returns true from all?' do
                expect(request.paths).to eq(:all)
                expect(request.all?).to eq(true)
            end
        end
    end

    describe '#satisfy' do
        it 'sets satisfied? to true' do
            request.satisfy(run_result_fixture(:success))
            expect(request.satisfied?).to eq(true)
        end

        it 'remembers result' do
            request.satisfy(run_result_fixture(:success))
            expect(request.result).to eq(run_result_fixture(:success))
        end
    end

    describe '#notify' do
        let(:request) { Guard::Jest::RunRequest.new(:all) }

        it 'notifys server of successful run' do
            expect(Guard::Jest::Formatter).to receive(:success).with(/2 specs, 0 failures/)
            expect(Guard::Jest::Formatter).to(
                receive(:notify).with(/2 specs, 0 failures/, title: "Jest suite passed")
            )
            expect(Guard::Jest::Formatter).to receive(:info).with(/Finished/)

            request.notify(run_result_fixture(:success))
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
