require 'thread'

require 'pra/window_system_factory'
require 'pra/pull_request_service'

Thread.abort_on_exception=true

module Pra
  class App
    def run
      @window_system = Pra::WindowSystemFactory.build('curses')
      @window_system.setup

      spawn_pull_request_fetcher

      @window_system.run_loop
    end

    def spawn_pull_request_fetcher
      Thread.new { pull_request_fetcher_thread }
    end

    def fetch_and_refresh_pull_requests
      @window_system.fetching_pull_requests
      pull_requests = Pra::PullRequestService.fetch_pull_requests
      @window_system.refresh_pull_requests(pull_requests)
      Kernel.sleep(5 * 60)
    end

    def pull_request_fetcher_thread
      while( true ) do
        fetch_and_refresh_pull_requests
      end
    end
  end
end
