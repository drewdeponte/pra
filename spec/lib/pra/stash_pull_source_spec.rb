require_relative "../../../lib/pra/stash_pull_source"

describe Pra::StashPullSource do
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
      pull_source = Pra::StashPullSource.new(config)
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
      pull_source = Pra::StashPullSource.new(config)
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
      pull_source = Pra::StashPullSource.new(config)
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
      pull_source = Pra::StashPullSource.new(config)
      pull_source.stub(:rest_api_pull_request_resource).with({ "project_slug" => "CAP", "repository_slug" => "capture_api" }).and_return('{ "values": [] }')
      pull_source.get_repo_pull_requests({ "project_slug" => "CAP", "repository_slug" => "capture_api" })
    end
  end

  describe "#rest_api_pull_request_url" do
    context "when config is for a user repository" do
      let(:config) do
        {
          "protocol" => "https",
          "host" => "my.stash.instance",
          "username" => "foo",
          "password" => "bar",
          "repositories" => [
            { "user_slug" => "andrew.deponte", "repository_slug" => "capture_api" }
          ]
        }
      end

      it "returns the user pull request url compiled from the config options" do
        pull_source = Pra::StashPullSource.new(config)
        expect(pull_source.rest_api_pull_request_url({ "user_slug" => "andrew.deponte", "repository_slug" => "capture_api" })).to eq("https://my.stash.instance/rest/api/1.0/users/andrew.deponte/repos/capture_api/pull-requests")
      end
    end

    context "when config is for a project repository" do
      let(:config) do
        {
          "protocol" => "https",
          "host" => "my.stash.instance",
          "username" => "foo",
          "password" => "bar",
          "repositories" => [
            { "project_slug" => "CAP", "repository_slug" => "capture_api" }
          ]
        }
      end
      
      it "returns the project pull request url compiled from the config options" do
        pull_source = Pra::StashPullSource.new(config)
        pull_source.rest_api_pull_request_url({ "project_slug" => "CAP", "repository_slug" => "capture_api" }).should eq("https://my.stash.instance/rest/api/1.0/projects/CAP/repos/capture_api/pull-requests")
      end
    end
  end

  describe "#rest_api_pull_request_resource" do
    let(:config) do
      {
        "protocol" => "https",
        "host" => "my.stash.instance",
        "username" => "foo",
        "password" => "bar",
        "repositories" => [
          { "project_slug" => "CAP", "repository_slug" => "capture_api" }
        ]
      }
    end

    let(:repo_config) { {"project_slug" => "CAP", "repository_slug" => "capture_api"} }

    subject { Pra::StashPullSource.new(config) }

    it "creates a Faraday connection" do
      expect(Faraday).to receive(:new).and_return(double.as_null_object)
      subject.rest_api_pull_request_resource(repo_config)
    end

    it "set the http basic auth credentials" do
      conn = double('faraday connection').as_null_object
      allow(Faraday).to receive(:new).and_return(conn)
      expect(conn).to receive(:basic_auth).with("foo", "bar")
      subject.rest_api_pull_request_resource(repo_config)
    end

    it "makes request using faraday connection" do
      conn = double('faraday connection').as_null_object
      allow(Faraday).to receive(:new).and_return(conn)
      expect(conn).to receive(:get)
      subject.rest_api_pull_request_resource(repo_config)
    end

    it "returns the responses body" do
      conn = double('faraday connection').as_null_object
      allow(Faraday).to receive(:new).and_return(conn)
      expect(conn).to receive(:get).and_return(double('response', body: 'hoopytbody'))
      expect(subject.rest_api_pull_request_resource(repo_config)).to eq('hoopytbody')
    end
  end
end
