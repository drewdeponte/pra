require 'pra/pull_source'
require 'pra/pull_request'
require 'pra/log'
require 'json'
require "graphql/client"
require "graphql/client/http"

module Pra
  class GithubGraphQLPullSource
    def pull_requests
      # TODO: build a pra pull request entity
      Pra::PullRequest.new(title: request["title"],
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

    def pull_requests
      @pull_requests ||= fetch_pull_requests
    end

    def fetch_pull_requests
      client.query(UserOrganizationPullRequestQuery)
    end

    def client
      @client ||= Client.new(@config['personal_access_token'])
    end

    class Client < GraphQL::Client
      class GithubHTTPClient < GraphQL::Client::HTTP
        def initialize(url, token)
          @token = token
          super(url)
        end

        def headers(_)
          { 'Authorization' => "bearer #{@token}" }
        end
      end

      def initialize(token)
        http = GithubHTTPClient.new("https://api.github.com/graphql", token)
        schema = GraphQL::Client.load_schema(http)
        super(schema: schema, execute: http)
      end
    end

    UserOrganizationPullRequestQuery = GraphQL::Client.new().parse <<-'GRAPHQL'
      {
        viewer {
          organizations(first: 30) {
            edges {
              node {
                id
                name
                repositories(first: 30) {
                  edges {
                    node {
                      id
                      name
                      pullRequests(first:30) {
                        edges {
                          node {
                            id
                            title
                            author {
                              name
                            }
                          }
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
    GRAPHQL
  end
end

# require 'pra/github_graphql_pull_source'; ps = Pra::GithubGraphQLPullSource.new
