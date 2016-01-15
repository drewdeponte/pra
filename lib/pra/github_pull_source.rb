require 'pra/pull_source'
require 'pra/pull_request'
require 'json'
require 'faraday'

module Pra
  class GithubPullSource < Pra::PullSource
    def organization_repositories
      repo_configs = []
      organizations.each do |org_config|
        repo_configs.concat(get_organization_repos(org_config))
      end
      return repo_configs
    end

    def organizations
      @config["organizations"] || []
    end

    def get_organization_repos(org_config)
      repos = []
      JSON.parse(rest_api_orgnanization_repositories_resource(org_config)).each do |request|
        unless org_config["exclude"].include?(request["name"])
          repos << { "owner" => org_config["name"], "repository" => request["name"] }
        end
      end
      return repos
    end

    def pull_requests
      repo_configs = organization_repositories
      repo_configs += repositories

      requests = []
      repo_configs.uniq.each do |repo_config|
        requests.concat(get_repo_pull_requests(repo_config))
      end
      return requests
    end

    def repositories
      @config["repositories"] || []
    end

    def get_repo_pull_requests(repository_config)
      requests = []
      begin 
        JSON.parse(rest_api_pull_request_resource(repository_config)).each do |request|
          requests << Pra::PullRequest.new(title: request["title"], from_reference: request["head"]["label"], to_reference: request["base"]["label"], author: request["user"]["login"], assignee: request["assignee"] ? request["assignee"]["login"] : nil, link: request['html_url'], service_id: 'github', repository: repository_config["repository"])
        end
      rescue => e
        Pra::ErrorLog.log(e.message)
      end
      return requests
      end

    def rest_api_pull_request_url(repository_config)
      "#{@config['protocol']}://#{@config['host']}/repos/#{repository_config["owner"]}/#{repository_config["repository"]}/pulls"
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

    def rest_api_org_repo_url(org_config)
      "#{@config['protocol']}://#{@config['host']}/orgs/#{org_config["name"]}/repos"
    end

    def rest_api_orgnanization_repositories_resource(org_config)
      conn = Faraday.new
      conn.basic_auth(@config['username'], @config['password'])
      resp = conn.get do |req|
        req.url rest_api_org_repo_url(org_config)
        req.headers['Content-Type'] = 'application/json'
        req.headers['Accept'] = 'application/json'
      end
      resp.body
    end
  end
end
