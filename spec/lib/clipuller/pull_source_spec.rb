require_relative "../../../lib/clipuller/pull_source"

describe Clipuller::PullSource do
  describe "#initialize" do
    it "assigns the given config hash to an instance variable" do
      config = double('config hash')
      pull_source = Clipuller::PullSource.new(config)
      pull_source.instance_variable_get(:@config).should eq(config)
    end
  end

  describe "#pull_requests" do
    it "raises an exception forcing inheriting classes to implement this method" do
      expect { subject.pull_requests }.to raise_error(Clipuller::PullSource::NotImplemented)
    end
  end
end
