require_relative "../../../lib/clipuller/app"

describe Clipuller::App do
  describe "#run" do
    it "builds the window system" do
      subject.stub(:spawn_pull_request_fetcher)
      window_system_double = double('window system', setup: nil, run_loop: nil)
      expect(Clipuller::WindowSystemFactory).to receive(:build).with('curses').and_return(window_system_double)
      subject.run
    end

    it "sets up the window system" do
      subject.stub(:spawn_pull_request_fetcher)
      window_system_double = double('window system', run_loop: nil)
      Clipuller::WindowSystemFactory.stub(:build).and_return(window_system_double)
      expect(window_system_double).to receive(:setup)
      subject.run
    end

    it "spawns the pull request fetcher thread" do
      window_system_double = double('window system', setup: nil, run_loop: nil)
      Clipuller::WindowSystemFactory.stub(:build).and_return(window_system_double)
      expect(subject).to receive(:spawn_pull_request_fetcher)
      subject.run
    end

    it "starts the window system run loop" do
      subject.stub(:spawn_pull_request_fetcher)
      window_system_double = double('window system', setup: nil, refresh_pull_requests: nil)
      Clipuller::WindowSystemFactory.stub(:build).and_return(window_system_double)
      expect(window_system_double).to receive(:run_loop)
      subject.run
    end
  end

  describe "#pull_request_fetcher_thread" do
    it "notifies the window system it is starting to fetch pull requests" do
      Kernel.stub(:sleep)
      Clipuller::PullRequestService.stub(:fetch_pull_requests)
      window_system_double = double('window system', refresh_pull_requests: nil)
      subject.instance_variable_set(:@window_system, window_system_double)
      expect(window_system_double).to receive(:fetching_pull_requests)
      subject.pull_request_fetcher_thread
    end

    it "fetches the pull requests from all of the sources" do
      Kernel.stub(:sleep)
      window_system_double = double('window system', refresh_pull_requests: nil, fetching_pull_requests: nil)
      subject.instance_variable_set(:@window_system, window_system_double)
      expect(Clipuller::PullRequestService).to receive(:fetch_pull_requests)
      subject.pull_request_fetcher_thread
    end

    it "tells the window system to refresh pull requests" do
      Kernel.stub(:sleep)
      pull_requests = double('fetched pull requests')
      Clipuller::PullRequestService.stub(:fetch_pull_requests).and_return(pull_requests)
      window_system_double = double('window system', fetching_pull_requests: nil)
      subject.instance_variable_set(:@window_system, window_system_double)
      expect(window_system_double).to receive(:refresh_pull_requests).with(pull_requests)
      subject.pull_request_fetcher_thread
    end

    it "sleeps for the polling frequency" do
      window_system_double = double('window system', refresh_pull_requests: nil, fetching_pull_requests: nil)
      subject.instance_variable_set(:@window_system, window_system_double)
      Clipuller::PullRequestService.stub(:fetch_pull_requests)
      expect(Kernel).to receive(:sleep)
      subject.pull_request_fetcher_thread
    end
  end
end
