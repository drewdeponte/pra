require_relative "../../../lib/clipuller/stash_pull_source"

describe Clipuller::StashPullSource do
  describe "#pull_requests" do
    it "gets all the repositories" do
      subject.should_receive(:repositories).and_return([])
      subject.pull_requests
    end

    it "gets the pull requests for each repository" do
      config = {
        "protocol" => "https",
        "host" => "my.stash.instance",
        "username" => "foo",
        "password" => "bar",
        "repositories" => [
          { "project_slug" => "CAP", "repository_slug" => "capture_api" }
        ]
      }
      pull_source = Clipuller::StashPullSource.new(config)
      pull_source.should_receive(:get_repo_pull_requests).with({ "project_slug" => "CAP", "repository_slug" => "capture_api" }).and_return([])
      pull_source.pull_requests
    end

    it "returns the collection of all of the pull requests for the configured repos" do
      config = {
        "protocol" => "https",
        "host" => "my.stash.instance",
        "username" => "foo",
        "password" => "bar",
        "repositories" => [
          { "project_slug" => "CAP", "repository_slug" => "capture_api" },
          { "project_slug" => "CAP", "repository_slug" => "capture_crawler_api" }
        ]
      }
      pull_request_one = double('pull request one')
      pull_request_two = double('pull request two')
      pull_source = Clipuller::StashPullSource.new(config)
      pull_source.stub(:get_repo_pull_requests).with({ "project_slug" => "CAP", "repository_slug" => "capture_api" }).and_return([pull_request_one])
      pull_source.stub(:get_repo_pull_requests).with({ "project_slug" => "CAP", "repository_slug" => "capture_crawler_api" }).and_return([pull_request_two])
      pull_source.pull_requests.should eq([pull_request_one, pull_request_two])
    end
  end

  describe "#repositories" do
    it "returns the repositories segment of the config" do
      config = {
        "protocol" => "https",
        "host" => "my.stash.instance",
        "username" => "foo",
        "password" => "bar",
        "repositories" => [
          { "project_slug" => "CAP", "repository_slug" => "capture_api" }
        ]
      }
      pull_source = Clipuller::StashPullSource.new(config)
      pull_source.repositories.should eq([{ "project_slug" => "CAP", "repository_slug" => "capture_api" }])
    end
  end
  
  describe "#get_repo_pull_requests" do
    it "requests the pull requests for the given repo" do
      config = {
        "protocol" => "https",
        "host" => "my.stash.instance",
        "username" => "foo",
        "password" => "bar",
        "repositories" => [
          { "project_slug" => "CAP", "repository_slug" => "capture_api" }
        ]
      }
      pull_source = Clipuller::StashPullSource.new(config)
      the_url = double
      pull_source.stub(:stash_rest_api_pull_request_url).with({ "project_slug" => "CAP", "repository_slug" => "capture_api" }).and_return(the_url)
      RestClient.should_receive(:get).with(the_url, anything).and_return('{ "values": [] }')
      pull_source.get_repo_pull_requests({ "project_slug" => "CAP", "repository_slug" => "capture_api" })
    end
  end

  describe "#stash_rest_api_pull_request_url" do
    it "returns the pull request url compiled from the config options" do
      config = {
        "protocol" => "https",
        "host" => "my.stash.instance",
        "username" => "foo",
        "password" => "bar",
        "repositories" => [
          { "project_slug" => "CAP", "repository_slug" => "capture_api" }
        ]
      }
      pull_source = Clipuller::StashPullSource.new(config)
      pull_source.stash_rest_api_pull_request_url({ "project_slug" => "CAP", "repository_slug" => "capture_api" }).should eq("https://foo:bar@my.stash.instance/rest/api/1.0/projects/CAP/repos/capture_api/pull-requests")
    end
  end
end
