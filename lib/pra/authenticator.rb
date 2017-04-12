module Pra
  class Authenticator
    MFA_REQUIRED = 'Your account has 2FA enabled'.freeze
    UNAUTHORIZED = 'Unauthorized'.freeze
    UNKNOWN = 'Unknown error'.freeze
    MFA_RETRY_LIMIT = 3

    def run
      username, password = InputHandler.get_username, InputHandler.get_password
      mfa_token = nil
      mfa_attempts = 0
      begin
        github_token = TokenFetcher.fetch_token(username, password, mfa_token)
      rescue TokenFetcher::MfaRequired
        abort if mfa_attempts == MFA_RETRY_LIMIT
        puts MFA_REQUIRED if mfa_attempts.zero?
        mfa_token = InputHandler.get_mfa_token
        mfa_attempts += 1
        retry
      rescue TokenFetcher::Unauthorized
        puts UNAUTHORIZED
        abort
      rescue
        puts UNKNOWN
        abort
      end
      puts("Insert the following token as your Github Password in ~/.pra.json: #{github_token}")
    end
  end
end

require_relative 'authenticator/input_handler'
require_relative 'authenticator/token_fetcher'
