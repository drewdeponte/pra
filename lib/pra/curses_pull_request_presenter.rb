require 'pra/config'
require 'time-lord'

module Pra
  class CursesPullRequestPresenter
    def initialize(pull_request)
      @pull_request = pull_request
    end

    def repository
      force_length(@pull_request.repository, 20)
    end

    def title
      force_length(@pull_request.title, 40)
    end

    def from_reference
      force_length(@pull_request.from_reference, 20)
    end

    def to_reference
      force_length(@pull_request.to_reference, 20)
    end

    def author
      force_length(@pull_request.author, 14)
    end

    def assignee
      return force_length('', 14) if @pull_request.assignee.nil? || blacklisted?(@pull_request.assignee)
      force_length(@pull_request.assignee, 14)
    end

    def service_id
      force_length(@pull_request.service_id, 8)
    end

    def labels
      force_length(@pull_request.labels, 12)
    end

    def updated_at
      last_updated_words = @pull_request.updated_at.to_time.ago.to_words
      force_length(last_updated_words, 16)
    end

    def assignee_blacklist
      config = Pra::Config.load_config
      config.assignee_blacklist
    end

    def to_s
      "#{repository}\t#{title}\t#{author}\t#{assignee}\t#{labels}\t#{updated_at}"
    end

    private

    def force_length(string, length)
      string.ljust(length)[0..length - 1]
    end

    def blacklisted?(assignee)
      assignee_blacklist.include?(assignee)
    end
  end
end
