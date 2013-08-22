require 'pra/stash_pull_source'
require 'pra/github_pull_source'

module Pra
  module PullSourceFactory
    def self.build_pull_source(pull_source_config)
      klass = map_type_to_klass(pull_source_config["type"])
      klass.new(pull_source_config["config"])
    end

    def self.map_type_to_klass(type)
      case type
      when 'stash'
        return StashPullSource
      when 'github'
        return GithubPullSource
      end
    end
  end
end
