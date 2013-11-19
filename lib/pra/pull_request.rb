module Pra
  class PullRequest
    attr_accessor :title, :from_reference, :to_reference, :author, :assignee, :link, :service_id, :repository

    def initialize(attributes={})
      @title = attributes[:title]
      @from_reference = attributes[:from_reference]
      @to_reference = attributes[:to_reference]
      @author = attributes[:author]
      @assignee = attributes[:assignee]
      @link = attributes[:link]
      @service_id = attributes[:service_id]
      @repository = attributes[:repository]
    end

    def assignee
      @assignee || ""
    end
  end
end
