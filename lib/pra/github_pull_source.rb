require 'pra/pull_source'
require 'pra/pull_request'
require 'rest_client'
require 'json'

module Pra
  class GithubPullSource < Pra::PullSource
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
      JSON.parse(rest_api_pull_request_resource(repository_config).get).each do |request|
        requests << Pra::PullRequest.new(title: request["title"], from_reference: request["head"]["label"], to_reference: request["base"]["label"], author: request["user"]["login"], assignee: request["assignee"] ? request["assignee"]["login"] : nil, link: request['html_url'], service_id: 'github', repository: repository_config["repository"])
      end
      return requests
    end

    def rest_api_pull_request_url(repository_config)
      "#{@config['protocol']}://#{@config['host']}/repos/#{repository_config["owner"]}/#{repository_config["repository"]}/pulls"
    end

    def rest_api_pull_request_resource(repository_config)
      RestClient::Resource.new(rest_api_pull_request_url(repository_config), user: @config['username'], password: @config['password'], content_type: :json, accept: :json)
    end
  end
end
