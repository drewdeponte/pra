require_relative "../../../lib/pra/github_pull_source"

describe Pra::GithubPullSource do
  describe "#pull_requests" do
    it "gets all the repositories" do
      subject.should_receive(:repositories).and_return([])
      subject.pull_requests
    end

    it "gets the pull requests for each repository" do
      config = {
        "protocol" => "https",
        "host" => "my.github.instance",
        "username" => "foo",
        "password" => "bar",
        "repositories" => [
          { "owner" => "reachlocal", "repository" => "snapdragon" }
        ]
      }
      pull_source = Pra::GithubPullSource.new(config)
      pull_source.should_receive(:get_repo_pull_requests).with({ "owner" => "reachlocal", "repository" => "snapdragon" }).and_return([])
      pull_source.pull_requests
    end

    it "returns the collection of all of the pull requests for the configured repos" do
      config = {
        "protocol" => "https",
        "host" => "my.github.instance",
        "username" => "foo",
        "password" => "bar",
        "repositories" => [
          { "owner" => "reachlocal", "repository" => "snapdragon" },
          { "owner" => "realpractice", "repository" => "rliapi" }
        ]
      }
      pull_request_one = double('pull request one')
      pull_request_two = double('pull request two')
      pull_source = Pra::GithubPullSource.new(config)
      pull_source.stub(:get_repo_pull_requests).with({ "owner" => "reachlocal", "repository" => "snapdragon" }).and_return([pull_request_one])
      pull_source.stub(:get_repo_pull_requests).with({ "owner" => "realpractice", "repository" => "rliapi" }).and_return([pull_request_two])
      pull_source.pull_requests.should eq([pull_request_one, pull_request_two])
    end
  end

  describe "#repositories" do
    it "returns the repositories segment of the config" do
      config = {
        "protocol" => "https",
        "host" => "my.github.instance",
        "username" => "foo",
        "password" => "bar",
        "repositories" => [
          { "owner" => "reachlocal", "repository" => "snapdragon" }
        ]
      }
      pull_source = Pra::GithubPullSource.new(config)
      pull_source.repositories.should eq([{ "owner" => "reachlocal", "repository" => "snapdragon" }])
    end
  end
  
  describe "#get_repo_pull_requests" do
    it "requests the pull requests for the given repo" do
      config = {
        "protocol" => "https",
        "host" => "my.github.instance",
        "username" => "foo",
        "password" => "bar",
        "repositories" => [
          { "owner" => "reachlocal", "repository" => "snapdragon" }
        ]
      }
      pull_source = Pra::GithubPullSource.new(config)
      the_resource = double
      pull_source.stub(:rest_api_pull_request_resource).with({ "owner" => "reachlocal", "repository" => "snapdragon" }).and_return(the_resource)
      the_resource.should_receive(:get).and_return('[]')
      pull_source.get_repo_pull_requests({ "owner" => "reachlocal", "repository" => "snapdragon" })
    end
  end

  describe "#rest_api_pull_request_url" do
    let(:config) do
      {
        "protocol" => "https",
        "host" => "my.github.instance",
        "username" => "foo",
        "password" => "bar",
        "repositories" => [
          { "owner" => "reachlocal", "repository" => "snapdragon" }
        ]
      }
    end

    it "returns the pull request url compiled from the config options" do
      pull_source = Pra::GithubPullSource.new(config)
      pull_source.rest_api_pull_request_url({ "owner" => "reachlocal", "repository" => "snapdragon" }).should eq("https://my.github.instance/repos/reachlocal/snapdragon/pulls")
    end
  end

  describe "#rest_api_pull_request_resource" do
    let(:config) do
      {
        "protocol" => "https",
        "host" => "my.github.instance",
        "username" => "foo",
        "password" => "bar",
        "repositories" => [
          { "owner" => "reachlocal", "repository" => "snapdragon" }
        ]
      }
    end

    let(:repo_config) { {"owner" => "reachlocal", "repository" => "snapdragon"} }

    subject { Pra::GithubPullSource.new(config) }

    it "gets the repository url compiled from the config options" do
      subject.should_receive(:rest_api_pull_request_url).with(repo_config)
      subject.rest_api_pull_request_resource(repo_config)
    end

    it "builds a restclient resource using the pull request url and user credentials" do
      url = "https://my.github.instance/repos/reachlocal/snapdragon/pulls"
      subject.stub(:rest_api_pull_request_url).and_return(url)
      RestClient::Resource.should_receive(:new).with(url, {user: "foo", password: "bar", content_type: :json, accept: :json})
      subject.rest_api_pull_request_resource(repo_config)
    end
  end
end
