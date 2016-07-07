require 'json'
require 'faraday'

module Pra
  class Authenticator
    class TokenFetcher
      GITHUB_AUTH_URL = 'https://api.github.com/authorizations'.freeze
      SCOPES = ['repo'.freeze].freeze
      NOTE = 'Pra'.freeze

      def self.fetch_token(username, password, mfa_token)
        conn = Faraday.new
        conn.basic_auth(username, password)
        response = conn.post do |req|
          req.url GITHUB_AUTH_URL
          req.body = body
          req.headers['Content-Type'] = 'application/json'
          req.headers['Accept'] = 'application/json'
          req.headers['X-GitHub-OTP'] = mfa_token if mfa_token
        end
        handle_errors(response) unless response.status == 201
        return JSON.parse(response.body)['token']
      end

      def self.body
        return { scopes: SCOPES, note: note }.to_json
      end

      def self.handle_errors(response)
        if mfa_required?(response)
          raise MfaRequired
        elsif unauthorized?(response)
          raise Unauthorized
        else
          raise UnknownError
        end
      end

      def self.mfa_required?(response)
        return response.status == 401 && response.headers['x-github-otp'] &&\
         response.headers['x-github-otp'].include?('required')
      end

      def self.unauthorized?(response)
        return response.status == 401
      end

      def self.note
        return "#{NOTE} - #{Time.now.to_i}"
      end

      class MfaRequired < StandardError; end;
      class Unauthorized < StandardError; end;
      class UnknownError < StandardError; end;
    end
  end
end
