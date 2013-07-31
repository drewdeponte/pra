require 'clipuller/pull_source'
require 'clipuller/pull_request'
require 'rest_client'
require 'json'

module Clipuller
  class StashPullSource < Clipuller::PullSource
    def pull_requests
      requests = []
      repositories.each do |repo_config|
        requests.concat(get_repo_pull_requests(repo_config))
      end
      return requests
    end

    def repositories
      @config["repositories"]
    end

    def get_repo_pull_requests(repository_config)
      requests = []
      JSON.parse(RestClient.get stash_rest_api_pull_request_url(repository_config), :content_type => :json, :accept => :json)["values"].each do |request|
        requests << Clipuller::PullRequest.new(title: request["title"], from_reference: request["fromRef"]["id"], to_reference: request["toRef"]["id"], author: request["author"]["user"]["name"], link: request["link"]["url"])
      end
      return requests
    end

    def stash_rest_api_pull_request_url(repository_config)
      "#{@config['protocol']}://#{@config['username']}:#{@config['password']}@#{@config['host']}/rest/api/1.0/projects/#{repository_config["project_slug"]}/repos/#{repository_config["repository_slug"]}/pull-requests"
    end
  end
end
