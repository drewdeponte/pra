require 'pra/error_log'
require 'timecop'

describe Pra::ErrorLog do
  describe '.log' do
    let(:log_path) { double('log path') }
    let(:file) { double('file object', puts: nil) }
    let(:backtrace) { ['backtrace line 1', 'backtrace line 2'] }
    let(:error) { double('error', message: "some error message", backtrace: backtrace) }

    it 'opens the log file for appending' do
      allow(Pra::Config).to receive(:error_log_path).and_return(log_path)
      expect(File).to receive(:open).with(log_path, 'a')
      Pra::ErrorLog.log(double)
    end

    it 'prints the error message to the file' do
      cur_time = Time.new(2015, 7, 12)
      allow(File).to receive(:open).and_yield(file)
      Timecop.freeze(cur_time) do
        expect(file).to receive(:puts).with("2015-07-12T00:00:00-07:00 - some error message")
        Pra::ErrorLog.log(error)
      end
    end

    it 'prints the backtrace to the file' do
      allow(File).to receive(:open).and_yield(file)
      expect(file).to receive(:puts).with('backtrace line 1')
      expect(file).to receive(:puts).with('backtrace line 2')
      Pra::ErrorLog.log(error)
    end
  end
end
