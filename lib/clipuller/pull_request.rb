module Clipuller
  class PullRequest
    attr_accessor :title, :from_reference, :to_reference, :author, :link

    def initialize(attributes={})
      @title = attributes[:title]
      @from_reference = attributes[:from_reference]
      @to_reference = attributes[:to_reference]
      @author = attributes[:author]
      @link = attributes[:link]
    end
  end
end
