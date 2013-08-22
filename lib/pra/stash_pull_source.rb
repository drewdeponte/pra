require 'pra/pull_source'
require 'pra/pull_request'
require 'rest_client'
require 'json'

module Pra
  class StashPullSource < Pra::PullSource
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
      JSON.parse(rest_api_pull_request_resource(repository_config).get)["values"].each do |request|
        requests << Pra::PullRequest.new(title: request["title"], from_reference: request["fromRef"]["id"], to_reference: request["toRef"]["id"], author: request["author"]["user"]["name"], link: "#{@config['protocol']}://#{@config['host']}#{request['link']['url']}", service_id: 'stash', repository: repository_config["repository_slug"])
      end
      return requests
    end

    def rest_api_pull_request_url(repository_config)
      "#{@config['protocol']}://#{@config['host']}/rest/api/1.0/projects/#{repository_config["project_slug"]}/repos/#{repository_config["repository_slug"]}/pull-requests"
    end

    def rest_api_pull_request_resource(repository_config)
      RestClient::Resource.new(rest_api_pull_request_url(repository_config), user: @config['username'], password: @config['password'], content_type: :json, accept: :json)
    end
  end
end
