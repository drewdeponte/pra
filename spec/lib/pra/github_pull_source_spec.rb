require_relative "../../../lib/pra/github_pull_source"

describe Pra::GithubPullSource do
  describe "#get_all_pull_requests" do
    it "fetches pull requests" do
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
      expect(pull_source).to receive(:fetch_pull_requests).and_return({'items' => []})
      pull_source.get_all_pull_requests
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
      expect(pull_source.repositories).to eq([{ "owner" => "reachlocal", "repository" => "snapdragon" }])
    end
  end

  describe "#organizations" do
    it "returns the organizations segment of the config" do
      config = {
        "protocol" => "https",
        "host" => "my.github.instance",
        "username" => "foo",
        "password" => "bar",
        "organizations" => [
          { "name" => "reachlocal" }
        ]
      }
      pull_source = Pra::GithubPullSource.new(config)
      expect(pull_source.organizations).to eq([{"name" => "reachlocal"}])
    end
  end
end
