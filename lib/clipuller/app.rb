require 'thread'

require 'clipuller/window_system_factory'
require 'clipuller/pull_request_service'

module Clipuller
  class App
    def run
      @window_system = Clipuller::WindowSystemFactory.build('curses')
      @window_system.setup

      spawn_pull_request_fetcher

      @window_system.run_loop
    end

    def spawn_pull_request_fetcher
      Thread.new { pull_request_fetcher_thread }
    end

    def pull_request_fetcher_thread
      pull_requests = Clipuller::PullRequestService.fetch_pull_requests
      @window_system.refresh_pull_requests(pull_requests)
      Kernel.sleep(10)
    end
  end
end
