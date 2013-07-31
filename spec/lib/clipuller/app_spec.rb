require_relative "../../../lib/clipuller/app"

describe Clipuller::App do
  describe "#run" do
    it "drives" do
      subject.run
    end

    it "gets all open pull-requests" do
      outputter = double('outputter', draw: nil)
      Clipuller::PullRequestOutputter.stub(:new).and_return(outputter)
      subject.should_receive(:pull_requests).and_return([])
      subject.run
    end

    it "notifies the pull request outputter of each of the pull requests" do
      outputter = double('outputter', draw: nil)
      Clipuller::PullRequestOutputter.stub(:new).and_return(outputter)
      pull_request_one = double('pull request one')
      pull_request_two = double('pull request two')
      subject.stub(:pull_requests).and_return([pull_request_one, pull_request_two])
      outputter.should_receive(:add_pull_request).with(pull_request_one)
      outputter.should_receive(:add_pull_request).with(pull_request_two)
      subject.run
    end

    it "draws the screen with all the pull requests" do
      subject.stub(:pull_requests).and_return([])
      outputter = double('outputter')
      Clipuller::PullRequestOutputter.stub(:new).and_return(outputter)
      outputter.should_receive(:draw)
      subject.run
    end
  end

  describe "#pull_requests" do
    it "gets all the pull-request sources" do
      subject.should_receive(:pull_sources).and_return([])
      subject.pull_requests
    end

    it "gets the pull requests from each pull-request source" do
      pull_source_one = double('pull source one')
      pull_source_two = double('pull source two')
      subject.stub(:pull_sources).and_return([pull_source_one, pull_source_two])
      pull_source_one.should_receive(:pull_requests).and_return([])
      pull_source_two.should_receive(:pull_requests).and_return([])
      subject.pull_requests
    end

    it "returns an array of all the pull-requests from each of the sources" do
      pull_request_one = double('pull request one')
      pull_request_two = double('pull request two')
      pull_source_one = double('pull source one', :pull_requests => [pull_request_one])
      pull_source_two = double('pull source two', :pull_requests => [pull_request_two])
      subject.stub(:pull_sources).and_return([pull_source_one, pull_source_two])
      subject.pull_requests.should eq([pull_request_one, pull_request_two])
    end
  end

  describe "#pull_sources" do
    it "gets the users config" do
      subject.stub(:map_config_to_pull_sources)
      Clipuller::Config.should_receive(:load_config)
      subject.pull_sources
    end

    it "maps the pull-request sources from the config to PullSource objects" do
      config = double('users config')
      Clipuller::Config.stub(:load_config).and_return(config)
      subject.should_receive(:map_config_to_pull_sources).with(config)
      subject.pull_sources
    end

    it "returns the mapped pull-request sources" do
      Clipuller::Config.stub(:load_config)
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
      Clipuller::PullSourceFactory.should_receive(:build_pull_source).with(pull_source_config_one)
      Clipuller::PullSourceFactory.should_receive(:build_pull_source).with(pull_source_config_two)
      subject.map_config_to_pull_sources(config)
    end

    it "returns an array of the constructed PullSource based objects" do
      pull_source_one = double('pull source one')
      pull_source_two = double('pull source two')
      pull_source_config_one = double('pull source config one')
      pull_source_config_two = double('pull source config two')
      config = double('config', pull_sources: [pull_source_config_one, pull_source_config_two])
      Clipuller::PullSourceFactory.stub(:build_pull_source).with(pull_source_config_one).and_return(pull_source_one)
      Clipuller::PullSourceFactory.stub(:build_pull_source).with(pull_source_config_two).and_return(pull_source_two)
      subject.map_config_to_pull_sources(config).should eq([pull_source_one, pull_source_two])
    end
  end
end
