require 'pra/error_log'

describe Pra::ErrorLog do
  describe '.log' do
    let(:log_path) { double('log path') }
    let(:file) { double('file object', puts: nil) }
    let(:message) { double('error message') }
    let(:backtrace) { ['backtrace line 1', 'backtrace line 2'] }
    let(:error) { double('error', message: message, backtrace: backtrace) }

    it 'opens the log file for appending' do
      allow(Pra::Config).to receive(:error_log_path).and_return(log_path)
      expect(File).to receive(:open).with(log_path, 'a')
      Pra::ErrorLog.log(double)
    end

    it 'prints the error message to the file' do
      allow(File).to receive(:open).and_yield(file)
      expect(file).to receive(:puts).with(message)
      Pra::ErrorLog.log(error)
    end

    it 'prints the backtrace to the file' do
      allow(File).to receive(:open).and_yield(file)
      expect(file).to receive(:puts).with('backtrace line 1')
      expect(file).to receive(:puts).with('backtrace line 2')
      Pra::ErrorLog.log(error)
    end
  end
end