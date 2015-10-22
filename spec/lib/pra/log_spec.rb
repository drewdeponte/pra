require 'pra/log'
require 'timecop'

describe Pra::Log do
  describe '.log' do
    let(:log_path) { double('log path') }
    let(:file) { double('file object', puts: nil) }
    let(:backtrace) { ['backtrace line 1', 'backtrace line 2'] }

    it 'opens the log file for appending' do
      allow(Pra::Config).to receive(:log_path).and_return(log_path)
      expect(File).to receive(:open).with(log_path, 'a')
      Pra::Log.log(double)
    end

    it 'prints the message to the file' do
      cur_time = Time.new(2015, 7, 12)
      allow(File).to receive(:open).and_yield(file)
      Timecop.freeze(cur_time) do
        expect(file).to receive(:puts).with("2015-07-12T00:00:00-07:00 - some message")
        Pra::Log.log("some message")
      end
    end
  end
end
