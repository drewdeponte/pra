require 'thread'

require 'pra/window_system_factory'
require 'pra/pull_request_service'
require 'pra/log'

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
      if @window_system.force_refresh || Time.now - @window_system.last_updated > refresh_interval
        @window_system.force_refresh = false
        @window_system.fetching_pull_requests
        new_pull_requests = []

        Pra::PullRequestService.fetch_pull_requests do |fetch|
          fetch.on_success do |pull_requests|
            new_pull_requests += pull_requests
          end

          fetch.on_error do |error|
            Pra::Log.error(error)
            @window_system.fetch_failed
          end
        end

        @window_system.refresh_pull_requests(new_pull_requests)
      end
      
      Kernel.sleep(0.1)
    end

    def pull_request_fetcher_thread
      while( true ) do
        fetch_and_refresh_pull_requests
      end
    end
    
    def refresh_interval
      config = Pra::Config.load_config
      config.refresh_interval
    end
  end
end
