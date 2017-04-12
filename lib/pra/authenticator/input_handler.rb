module Pra
  class Authenticator
    class InputHandler
      GITHUB_USERNAME = 'Github username: '.freeze
      GITHUB_PASSWORD = 'Github password: '.freeze
      GITHUB_MFA_TOKEN = 'Github 2FA Token: '.freeze

      def self.get_username
        print GITHUB_USERNAME
        gets.chomp
      end

      def self.get_password
        `stty -echo`
        print GITHUB_PASSWORD
        pw = gets.chomp
        `stty echo`
        puts ''
        return pw
      end

      def self.get_mfa_token
        print GITHUB_MFA_TOKEN
        gets.chomp
      end
    end
  end
end
