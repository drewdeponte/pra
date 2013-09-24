module Pra
  module PullRequestService
    class FetchStatus
      attr_reader :status, :pull_requests, :error

      def self.success(pull_requests)
        new(:success, pull_requests)
      end
      
      def self.error(error)
        new(:error, :no_pull_requests, error)
      end

      def initialize(status, pull_requests, error = nil)
        @status = status
        @pull_requests = pull_requests
        @error = error
      end

      def on_success &block
        yield(@pull_requests) if success?
      end

      def on_error &block
        yield(@error) if error?
      end

      def success?
        status == :success
      end

      def error?
        status == :error
      end
    end
  end
end