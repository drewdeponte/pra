require 'pra/pull_source'
require 'pra/pull_request'
require 'faraday'
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
      JSON.parse(rest_api_pull_request_resource(repository_config))["values"].each do |request|
        requests << Pra::PullRequest.new(title: request["title"], from_reference: request["fromRef"]["id"], to_reference: request["toRef"]["id"], assignee: request["reviewers"].length > 0 ? request["reviewers"].first["user"]["name"] : nil, author: request["author"]["user"]["name"], link: "#{@config['protocol']}://#{@config['host']}#{request['link']['url']}", service_id: 'stash', repository: repository_config["repository_slug"])
      end
      return requests
    end

    def rest_api_pull_request_url(repository_config)
      if repository_config.has_key?("user_slug")
        "#{@config['protocol']}://#{@config['host']}/rest/api/1.0/users/#{repository_config["user_slug"]}/repos/#{repository_config["repository_slug"]}/pull-requests"
      else
        "#{@config['protocol']}://#{@config['host']}/rest/api/1.0/projects/#{repository_config["project_slug"]}/repos/#{repository_config["repository_slug"]}/pull-requests"
      end
    end

    def rest_api_pull_request_resource(repository_config)
      conn = Faraday.new
      conn.basic_auth(@config['username'], @config['password'])
      resp = conn.get do |req|
        req.url rest_api_pull_request_url(repository_config)
        req.headers['Content-Type'] = 'application/json'
        req.headers['Accept'] = 'application/json'
      end
      resp.body
    end
  end
end
