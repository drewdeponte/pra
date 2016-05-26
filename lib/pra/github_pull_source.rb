require 'pra/pull_source'
require 'pra/pull_request'
require 'pra/log'
require 'json'
require 'faraday'

module Pra
  class GithubPullSource < Pra::PullSource
    def initialize(config = {})
      @ratelimit_remaining = 5000
      @ratelimit_limit = 5000
      @ratelimit_reset = nil
      super(config)
    end

    def pull_requests
      return get_all_pull_requests
    end

    def get_all_pull_requests
      pull_requests = []
      pull_requests_json = "[]"

      conn = Faraday.new
      conn.basic_auth(@config['username'], @config['password'])
      resp = conn.get do |req|
        req.url rest_api_search_issues_url
        req.params['q'] = "is:pr is:open sort:updated-desc #{repos_for_query}"
        req.params['per_page'] = '300'
        req.headers['Content-Type'] = 'application/json'
        req.headers['Accept'] = 'application/json'
      end

      @ratelimit_reset = Time.at(resp.headers['x-ratelimit-reset'].to_i)
      @ratelimit_limit = resp.headers['x-ratelimit-limit'].to_i
      @ratelimit_remaining = resp.headers['x-ratelimit-remaining'].to_i
      Pra::Log.info("fetched pull requests and updated ratelimit tracking")
      Pra::Log.info("Ratelimit Reset: #{@ratelimit_reset}")
      Pra::Log.info("Ratelimit Limit: #{@ratelimit_limit}")
      Pra::Log.info("Ratelimit Remaining: #{@ratelimit_remaining}")
      pull_requests_json = resp.body
      Pra::Log.debug(pull_requests_json)
      pull_requests_hash = JSON.parse(pull_requests_json)
      pull_requests_hash['items'].each do |request|
        begin
          org, repository = extract_repository_from_html_url(request['html_url'])
          unless excluded?(org, repository)
            pull_requests << Pra::PullRequest.new(title: request["title"],
                                                  from_reference: "",
                                                  to_reference: "",
                                                  author: request["user"]["login"],
                                                  assignee: request["assignee"] ? request["assignee"]["login"] : nil,
                                                  link: request['html_url'],
                                                  service_id: 'github',
                                                  repository: repository,
                                                  updated_at: request["updated_at"],
                                                  labels: request["labels"].collect{|l| l["name"]}.join(","))
          end
        rescue StandardError => e
          Pra::Log.error("Error: #{e.to_s}")
          Pra::Log.error("Request: #{request.inspect}")
        end
      end
      pull_requests
    end

    def repos_for_query
      query_params = [] 
      repositories.each do |repo|
        query_params << "repo:#{repo['owner']}/#{repo['repository']}"
      end

      @excluded_repos = {} 
      organizations.each do |org|
        query_params << "org:#{org['name']}"
        @excluded_repos[org['name'].downcase] = org['exclude']
      end

      return query_params.join(" ")
    end

    def excluded_repos
      @excluded_repos || collect_exclusions
    end

    def collect_exclusions
      @exclusions = {}
      organizations.each do |org|
        @exclusions[org['name'].downcase] = org['exclude']
      end
      @exclusions
    end

    def excluded?(org, repository)
      excluded_repos[org.downcase] && excluded_repos[org.downcase].include?(repository)
    end

    def extract_repository_from_html_url(html_url)
      /https:\/\/github.com\/(\w+)\/([\w-]+)/.match(html_url)
      return $1, $2
    end

    def rest_api_search_issues_url
      "#{@config['protocol']}://#{@config['host']}/search/issues"
    end

    def repositories
      @config["repositories"] || []
    end

    def organizations
      @config["organizations"] || []
    end

    def get_repo_pull_requests(repository_config)
      requests = []
      Pra::Log.info("get_repo_pull_requests - #{repository_config.inspect}")
      JSON.parse(rest_api_pull_request_resource(repository_config)).each do |request|
        begin
          requests << Pra::PullRequest.new(title: request["title"], from_reference: request["head"]["label"], to_reference: request["base"]["label"], author: request["user"]["login"], assignee: request["assignee"] ? request["assignee"]["login"] : nil, link: request['html_url'], service_id: 'github', repository: repository_config["repository"])
        rescue StandardError => e
          Pra::Log.error("Error: #{e.to_s}")
          Pra::Log.error("Request: #{request.inspect}")
        end
      end
      return requests
    end

    def rest_api_pull_request_url(repository_config)
      "#{@config['protocol']}://#{@config['host']}/repos/#{repository_config["owner"]}/#{repository_config["repository"]}/pulls"
    end

    def rest_api_pull_request_resource(repository_config)
      pull_requests_json = "[]"
      if @ratelimit_remaining > 0
        Pra::Log.info("rest_api_pull_request_resource - fetching pull requests")
        conn = Faraday.new
        conn.basic_auth(@config['username'], @config['password'])
        resp = conn.get do |req|
          req.url rest_api_pull_request_url(repository_config)
          req.headers['Content-Type'] = 'application/json'
          req.headers['Accept'] = 'application/json'
        end

        @ratelimit_reset = Time.at(resp.headers['x-ratelimit-reset'].to_i)
        @ratelimit_limit = resp.headers['x-ratelimit-limit'].to_i
        @ratelimit_remaining = resp.headers['x-ratelimit-remaining'].to_i
        Pra::Log.info("fetched pull requests and updated ratelimit tracking")
        Pra::Log.info("Ratelimit Reset: #{@ratelimit_reset}")
        Pra::Log.info("Ratelimit Limit: #{@ratelimit_limit}")
        Pra::Log.info("Ratelimit Remaining: #{@ratelimit_remaining}")
        pull_requests_json = resp.body
      elsif Time.now.utc > @ratelimit_reset
        Pra::Log.info("rest_api_pull_request_resource - fetching pull requests")
        conn = Faraday.new
        conn.basic_auth(@config['username'], @config['password'])
        resp = conn.get do |req|
          req.url rest_api_pull_request_url(repository_config)
          req.headers['Content-Type'] = 'application/json'
          req.headers['Accept'] = 'application/json'
        end

        @ratelimit_reset = Time.at(resp.headers['x-ratelimit-reset'].to_i)
        @ratelimit_limit = resp.headers['x-ratelimit-limit'].to_i
        @ratelimit_remaining = resp.headers['x-ratelimit-remaining'].to_i
        Pra::Log.info("fetched pull requests and updated ratelimit tracking")
        Pra::Log.info("Ratelimit Reset: #{@ratelimit_reset}")
        Pra::Log.info("Ratelimit Limit: #{@ratelimit_limit}")
        Pra::Log.info("Ratelimit Remaining: #{@ratelimit_remaining}")
        pull_requests_json = resp.body
      else
        Pra::Log.info("Skipping request because of ratelimit")
        Pra::Log.info("Ratelimit Reset: #{@ratelimit_reset}")
        Pra::Log.info("Ratelimit Limit: #{@ratelimit_limit}")
        Pra::Log.info("Ratelimit Remaining: #{@ratelimit_remaining}")
      end

      return pull_requests_json
    end
  end
end
