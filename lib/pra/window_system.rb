module Pra
  class WindowSystem
    class PureVirtualMethodNotImplemented < RuntimeError; end

    # This method is a pure virtual method and is intended for the inheriting
    # class to implement it in order to handle all the initialization and
    # setup of the windowing system the inheriting class is implementing.
    def setup
      raise PureVirtualMethodNotImplemented, "the 'setup' method needs to be implemented."
    end

    # This method is a pure virtual method and is called by the system
    # right before the fetching of the pull requests is started. It is simply
    # intended to be a notification to the window system so that it can notify
    # the user in whatever is an appropriate fashion that it is in the process
    # of fetching the pull requests.
    def fetching_pull_requests
      raise PureVirtualMethodNotImplemented, "the 'fetching_pull_requests' method needs to be implemented."
    end

    # This method is a pure virtual method and is intendend for the inheriting
    # class to implement it to handle refreshing the pull requests within in
    # the window system. This method is called evertime the pull request
    # fetching system fetches pull requests.
    def refresh_pull_requests(pull_requests)
      raise PureVirtualMethodNotImplemented, "the 'refresh_pull_requests' method needs to be implemented."
    end

    # This method is a pure virtual method and is intended for the inherting
    # class to implement it in order to initiate the main run loop of the
    # windowing system the inheriting class is implementing. It can also be
    # used to include any tear down that needs to happen when the run loop
    # exits.
    def run_loop
      raise PureVirtualMethodNotImplemented, "the 'run_loop' method needs to be implemented."
    end
  end
end
