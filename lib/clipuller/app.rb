require 'clipuller/pull_request_outputter'
require 'clipuller/config'
require 'clipuller/pull_source_factory'

module Clipuller
  class App
    def run
      outputter = Clipuller::PullRequestOutputter.new
      pull_requests.each do |pull_request|
        outputter.add_pull_request(pull_request)
      end
      outputter.draw
    end

    def pull_requests
      pull_requests = []
      pull_sources.each do |pull_source|
        pull_requests.concat(pull_source.pull_requests)
      end
      return pull_requests
    end

    def pull_sources
      config = Clipuller::Config.load_config
      return map_config_to_pull_sources(config)
    end

    def map_config_to_pull_sources(config)
      sources = []
      config.pull_sources.each do |pull_source_config|
        sources << Clipuller::PullSourceFactory.build_pull_source(pull_source_config)
      end
      return sources
    end
  end
end
