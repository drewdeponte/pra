require_relative '../../../lib/pra/pull_request_service'

describe Pra::PullRequestService do
  describe ".fetch_pull_requests" do
    it "gets all the pull-request sources" do
      subject.should_receive(:pull_sources).and_return([])
      subject.fetch_pull_requests
    end

    it "gets the pull requests from each pull-request source" do
      pull_source_one = double('pull source one')
      pull_source_two = double('pull source two')
      subject.stub(:pull_sources).and_return([pull_source_one, pull_source_two])
      pull_source_one.should_receive(:pull_requests).and_return([])
      pull_source_two.should_receive(:pull_requests).and_return([])
      subject.fetch_pull_requests
    end

    it "returns an array of all the pull-requests from each of the sources" do
      pull_request_one = double('pull request one')
      pull_request_two = double('pull request two')
      pull_source_one = double('pull source one', :pull_requests => [pull_request_one])
      pull_source_two = double('pull source two', :pull_requests => [pull_request_two])
      subject.stub(:pull_sources).and_return([pull_source_one, pull_source_two])
      subject.fetch_pull_requests.should eq([pull_request_one, pull_request_two])
    end
  end

  describe "#pull_sources" do
    it "gets the users config" do
      subject.stub(:map_config_to_pull_sources)
      Pra::Config.should_receive(:load_config)
      subject.pull_sources
    end

    it "maps the pull-request sources from the config to PullSource objects" do
      config = double('users config')
      Pra::Config.stub(:load_config).and_return(config)
      subject.should_receive(:map_config_to_pull_sources).with(config)
      subject.pull_sources
    end

    it "returns the mapped pull-request sources" do
      Pra::Config.stub(:load_config)
      sources = double('pull sources')
      subject.stub(:map_config_to_pull_sources).and_return(sources)
      subject.pull_sources.should eq(sources)
    end
  end

  describe "#map_config_to_pull_sources" do
    it "gets the pull sources from the config" do
      config = double('config')
      config.should_receive(:pull_sources).and_return([])
      subject.map_config_to_pull_sources(config)
    end

    it "creates a PullSource based object for each configured pull source" do
      pull_source_config_one = double('pull source config one')
      pull_source_config_two = double('pull source config two')
      config = double('config', pull_sources: [pull_source_config_one, pull_source_config_two])
      Pra::PullSourceFactory.should_receive(:build_pull_source).with(pull_source_config_one)
      Pra::PullSourceFactory.should_receive(:build_pull_source).with(pull_source_config_two)
      subject.map_config_to_pull_sources(config)
    end

    it "returns an array of the constructed PullSource based objects" do
      pull_source_one = double('pull source one')
      pull_source_two = double('pull source two')
      pull_source_config_one = double('pull source config one')
      pull_source_config_two = double('pull source config two')
      config = double('config', pull_sources: [pull_source_config_one, pull_source_config_two])
      Pra::PullSourceFactory.stub(:build_pull_source).with(pull_source_config_one).and_return(pull_source_one)
      Pra::PullSourceFactory.stub(:build_pull_source).with(pull_source_config_two).and_return(pull_source_two)
      subject.map_config_to_pull_sources(config).should eq([pull_source_one, pull_source_two])
    end
  end
end
