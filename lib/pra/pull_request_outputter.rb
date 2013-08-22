module Pra
  class PullRequestOutputter
    def initialize
      @pull_requests = []
    end

    def add_pull_request(request)
      @pull_requests << request
    end

    def draw
      puts "Title\t\t\t\tFrom Reference\tTo Reference\tAuthor"
      puts "-"*80
      @pull_requests.each do |request|
        puts "#{request.title}\t#{request.from_reference}\t#{request.to_reference}\t#{request.author}"
      end
    end
  end
end
