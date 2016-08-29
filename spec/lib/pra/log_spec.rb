require 'pra/log'
require 'timecop'

describe Pra::Log do
  subject { described_class }
  let(:logger) { spy('logger') }

  describe '.logger' do
    context "when logger has been memoized" do
      before do
        subject.instance_variable_set(:@logger, logger)
      end

      it "returns the memoized logger" do
        expect(subject.logger).to eq(logger)
      end
    end

    context "when logger has not been memoized" do
      let(:log_path) { double('log path') }
      let(:file) { double('file object', puts: nil) }
      let(:backtrace) { ['backtrace line 1', 'backtrace line 2'] }
      before do
        allow(Pra::Config).to receive(:log_path).and_return(log_path)
        subject.instance_variable_set(:@logger, nil)
      end

      it "creates a new logger" do
        expect(Logger).to receive(:new).with(log_path, 10, 5000000).and_return(logger)
        subject.logger
      end

      it "sets the formatter" do
        allow(Logger).to receive(:new).and_return(logger)
        # I have no idea how to set expectations on a proc correctly
        expect(logger).to receive(:formatter=)
        subject.logger
      end

      it "sets the log level to info" do
        allow(Logger).to receive(:new).and_return(logger)
        expect(logger).to receive(:level=).with(Logger::INFO)
        subject.logger
      end

      it "returns the created logger" do
        allow(Logger).to receive(:new).and_return(logger)
        expect(subject.logger).to eq(logger)
      end
    end
  end

  describe ".level" do
    before do
      subject.instance_variable_set(:@logger, logger)
    end

    it "sets the level on the logger" do
      expect(logger).to receive(:level=).with(Logger::DEBUG)
      subject.level("DEBUG")
    end
  end

  describe ".info" do
    before do
      subject.instance_variable_set(:@logger, logger)
    end

    it "logs a message at level INFO" do
      message = double('message')
      expect(logger).to receive(:info).with(message)
      subject.info(message)
    end
  end

  describe ".debug" do
    before do
      subject.instance_variable_set(:@logger, logger)
    end

    it "logs a message at level DEBUG" do
      message = double('message')
      expect(logger).to receive(:debug).with(message)
      subject.debug(message)
    end
  end

  describe ".error" do
    let(:message) { double('message') }

    before do
      subject.instance_variable_set(:@logger, logger)
    end

    it "logs a message at level ERROR" do
      expect(logger).to receive(:error).with(message)
      subject.error(message)
    end

    context "when backtrace is available" do
      before do
        allow(logger).to receive(:respond_to?).with(:backtrace).and_return(true)
      end

      it "logs the backtrace" do
        backtrace = double('backtrace')
        allow(message).to receive(:backtrace).and_return([backtrace])
        allow(logger).to receive(:error).with(message)
        expect(logger).to receive(:error).with(backtrace)
        subject.error(message)
      end
    end

    context "when backtrace is not available" do
      before do
        allow(logger).to receive(:respond_to?).with(:backtrace).and_return(false)
      end

      it "does not log the backtrace" do
        expect(logger).to receive(:error).once
        subject.error(message)
      end
    end
  end
end
