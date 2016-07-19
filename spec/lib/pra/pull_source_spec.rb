require_relative "../../../lib/pra/pull_source"

describe Pra::PullSource do
  describe "#initialize" do
    it "assigns the given config hash to an instance variable" do
      config = double('config hash')
      pull_source = Pra::PullSource.new(config)
      expect(pull_source.instance_variable_get(:@config)).to eq(config)
    end
  end

  describe "#pull_requests" do
    it "raises an exception forcing inheriting classes to implement this method" do
      expect { subject.pull_requests }.to raise_error(Pra::PullSource::NotImplemented)
    end
  end
end
