require_relative '../../spec_helper'
require 'ostruct'
require 'irb'

RSpec.describe Guard::Jest::Server do
    let(:options) { Guard::Jest::DEFAULT_OPTIONS }
    let(:server)  { Guard::Jest::Server.new(options) }
    let(:process) { OpenStruct.new(io: OpenStruct.new) }
    let(:expected_pty_command) { "#{options[:jest_cmd]} --json --silent true --watch" }

    describe '#initialize' do
        it 'does not start process' do
            expect(PTY).to_not receive(:spawn)
            Guard::Jest::Server.new(options)
        end
    end

    describe '#start' do
        it 'starts process' do
            expect(PTY).to receive(:spawn).with(expected_pty_command)
            Guard::Jest::Server.new(options).start
        end

        it 'starts in given directory' do
            expect(Dir).to receive(:chdir).with('/test-dir').and_yield
            expect(PTY).to receive(:spawn).with(expected_pty_command)
            Guard::Jest::Server.new(options.merge(directory: '/test-dir')).start
        end
    end

    describe 'running specs' do
        let(:server) { Guard::Jest::Server.new(options) }
        let(:io) { StringIO.new }
        let(:runner) { Guard::Jest::Runner.new(options) }
        let(:request) { Guard::Jest::RunRequest.new(runner, :all) }

        before(:each) do
            expect(server).to receive(:busy?).and_return false
            allow(server).to receive(:alive?).and_return true
            allow(server).to receive(:stdin).and_return(io)
        end

        it 'records request and marks as busy' do
            server.run(request)
            expect(server.pending.length).to eq(1)
        end

        it 'sends "a" command for #run_all' do
            expect(request).to receive(:all?).and_return true
            expect(io).to receive(:write).with('a')
            server.run(request)
        end

        it 'sends "p" and then paths for #run_paths' do
            expect(request).to receive(:all?).and_return false
            expect(request).to receive(:paths).and_return(%w(c d))

            expect(io).to receive(:write).with('p')
            expect(io).to receive(:write).with('c|d')
            expect(io).to receive(:write).with("\r")

            server.run(request)
        end
    end
end
