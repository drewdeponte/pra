require 'clipuller/pull_source'
require 'clipuller/pull_request'
require 'rest_client'
require 'json'

module Clipuller
  class GithubPullSource < Clipuller::PullSource
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
      JSON.parse(RestClient.get stash_rest_api_pull_request_url(repository_config), :content_type => :json, :accept => :json).each do |request|
        requests << Clipuller::PullRequest.new(title: request["title"], from_reference: request["head"]["label"], to_reference: request["base"]["label"], author: request["user"]["login"], link: request['html_url'], service_id: 'github', repository: repository_config["repository"])
      end
      return requests
    end

    def stash_rest_api_pull_request_url(repository_config)
      "#{@config['protocol']}://#{@config['username']}:#{@config['password']}@#{@config['host']}/repos/#{repository_config["owner"]}/#{repository_config["repository"]}/pulls"
    end
  end
end
