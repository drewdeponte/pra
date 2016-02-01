require 'pra/config'
require 'time-lord'

module Pra
  class CursesPullRequestPresenter
    def initialize(pull_request)
      @pull_request = pull_request
    end

    def repository
      @pull_request.repository
    end

    def title
      @pull_request.title
    end

    def from_reference
      @pull_request.from_reference
    end

    def to_reference
      @pull_request.to_reference
    end

    def author
      @pull_request.author
    end

    def assignee
      if @pull_request.assignee.nil? || blacklisted?(@pull_request.assignee)
        return ""
      else
        @pull_request.assignee
      end
    end

    def service_id
      @pull_request.service_id
    end

    def labels
      @pull_request.labels
    end

    def updated_at
      @pull_request.updated_at.to_time.ago.to_words
    end

    def assignee_blacklist
      Pra.config.assignee_blacklist
    end

    def present(columns)
      row = ""
      columns.each do |column|
        row << force_length(send(column[:name]), column[:size])
        row << (" " * column[:padding])
      end
      row
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
