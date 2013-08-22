module Pra
  class PullSource
    class NotImplemented < RuntimeError; end

    def initialize(config = {})
      @config = config
    end

    # This method is a pure virtual method and is intended to implemented by
    # all inheriting classes. It is responsible for obtaining and returning
    # the opened pull requests from the pull source. Note: These should be
    # returned as an array of Pra::PullRequest instances.
    def pull_requests
      raise NotImplemented, "The 'pull_requests' method needs to be implemented by the inheriting class"
    end
  end
end
