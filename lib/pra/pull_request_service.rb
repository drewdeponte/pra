require 'pra/config'
require 'pra/pull_source_factory'

module Pra
  module PullRequestService
    def self.fetch_pull_requests
      pull_requests = []
      pull_sources.each do |pull_source|
        pull_requests.concat(pull_source.pull_requests)
      end
      return pull_requests
    end

    def self.pull_sources
      config = Pra::Config.load_config
      return map_config_to_pull_sources(config)
    end

    def self.map_config_to_pull_sources(config)
      sources = []
      config.pull_sources.each do |pull_source_config|
        sources << Pra::PullSourceFactory.build_pull_source(pull_source_config)
      end
      return sources
    end
  end
end
