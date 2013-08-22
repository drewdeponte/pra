require_relative "../../../lib/pra/pull_source_factory"

describe Pra::PullSourceFactory do
  describe ".build_pull_source" do
    it "maps the pull source type to class" do
      pull_source_type_specific_configs = double('pull source type specific configs')
      pull_source_config = { "type" => "stash", "config" => pull_source_type_specific_configs }
      subject.should_receive(:map_type_to_klass).with("stash").and_return(Pra::StashPullSource)
      subject.build_pull_source(pull_source_config)
    end

    it "constructs the mapped PullSource based object using the given pull source type specific config" do
      pull_source_type_specific_configs = double('pull source type specific configs')
      pull_source_config = { "type" => "stash", "config" => pull_source_type_specific_configs }
      Pra::StashPullSource.should_receive(:new).with(pull_source_type_specific_configs)
      subject.build_pull_source(pull_source_config)
    end

    it "returns the instance of the previously constructed PullSource based object" do
      pull_source = double('the constructed pull source')
      pull_source_config = { "type" => "stash", "config" => {} }
      Pra::StashPullSource.should_receive(:new).and_return(pull_source)
      subject.build_pull_source(pull_source_config).should eq(pull_source)
    end
  end

  describe ".map_type_to_klass" do
    context "when given type is 'stash'" do
      it "returns the StashPullSource class" do
        subject.map_type_to_klass("stash").should eq(Pra::StashPullSource)
      end
    end

    context "When given type is 'github'" do
      it "returns the GithubPullSource class" do
        subject.map_type_to_klass("github").should eq(Pra::GithubPullSource)
      end
    end
  end
end
