require 'pra/config'
require 'pra/pull_source_factory'
require 'pra/pull_request_service/fetch_status'

module Pra
  module PullRequestService
    def self.fetch_pull_requests
      pull_sources.each do |pull_source|
        yield fetch_with_status(pull_source)
      end
    end

    def self.fetch_with_status(pull_source)
      pull_requests = pull_source.pull_requests
      FetchStatus.success(pull_requests)
    rescue Exception => error
      FetchStatus.error(error)
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
