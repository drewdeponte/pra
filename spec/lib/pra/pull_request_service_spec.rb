require_relative '../../../lib/pra/pull_request_service'

describe Pra::PullRequestService do
  describe ".fetch_pull_requests" do
    let(:pull_request_one) { double('pull request one') }
    let(:pull_request_two) { double('pull request two') }
    let(:pull_source_one) { double('good pull source one', :pull_requests => [pull_request_one]) }
    let(:pull_source_two) { double('good pull source two', :pull_requests => [pull_request_two]) }

    it "gets all the pull-request sources" do
      subject.should_receive(:pull_sources).and_return([])
      subject.fetch_pull_requests
    end

    it "gets the pull requests from each pull-request source" do
      allow(subject).to receive(:pull_sources).and_return([pull_source_one, pull_source_two])
      expect(subject).to receive(:fetch_with_status).with(pull_source_one)
      expect(subject).to receive(:fetch_with_status).with(pull_source_two)
      subject.fetch_pull_requests {}
    end

    it "yields each pull source with its fetch status object" do
      status1 = double
      status2 = double
      allow(subject).to receive(:pull_sources).and_return([pull_source_one, pull_source_two])
      allow(subject).to receive(:fetch_with_status).with(pull_source_one).and_return(status1)
      allow(subject).to receive(:fetch_with_status).with(pull_source_two).and_return(status2)
      expect { |b| subject.fetch_pull_requests(&b) }.to yield_successive_args(status1, status2)
    end
  end

  describe '.fetch_with_status' do
    let(:pulls) { double('pull requests') }
    let(:error) { Exception.new('error fetching pull requests') }
    let(:good_source) { double('good pull source', :pull_requests => pulls) }
    let(:bad_source) { double('bad pull source') }

    before do
      allow(bad_source).to receive(:pull_requests).and_raise(error)
    end

    context 'when it fetches successfully' do
      it 'builds a success status object for the requests from each pull source' do
        expect(Pra::PullRequestService::FetchStatus).to receive(:success).with(pulls)
        subject.fetch_with_status(good_source)
      end

      it 'returns the status object' do
        status = double('success status object')
        allow(Pra::PullRequestService::FetchStatus).to receive(:success).with(pulls).and_return(status)
        expect(subject.fetch_with_status(good_source)).to eq(status)
      end
    end

    context 'when fetching raises an exception' do
      it 'builds an error status object with the error' do
        expect(Pra::PullRequestService::FetchStatus).to receive(:error).with(error)
        subject.fetch_with_status(bad_source)
      end

      it 'returns the status object' do
        status = double('error status object')
        allow(Pra::PullRequestService::FetchStatus).to receive(:error).and_return(status)
        expect(subject.fetch_with_status(bad_source)).to eq(status)
      end
    end
  end

  describe "#pull_sources" do
    it "maps the pull-request sources from the config to PullSource objects" do
      subject.should_receive(:map_config_to_pull_sources)
      subject.pull_sources
    end

    it "returns the mapped pull-request sources" do
      sources = double('pull sources')
      subject.stub(:map_config_to_pull_sources).and_return(sources)
      subject.pull_sources.should eq(sources)
    end
  end

  describe "#map_config_to_pull_sources" do
    it "gets the users config" do
      config = double('config', pull_sources: [])
      Pra.should_receive(:config).and_return(config)
      subject.map_config_to_pull_sources
    end

    it "gets the pull sources from the config" do
      config = double('config')
      Pra.stub(:config).and_return(config)
      config.should_receive(:pull_sources).and_return([])
      subject.map_config_to_pull_sources
    end

    it "creates a PullSource based object for each configured pull source" do
      pull_source_config_one = double('pull source config one')
      pull_source_config_two = double('pull source config two')
      config = double('config', pull_sources: [pull_source_config_one, pull_source_config_two])
      Pra.stub(:config).and_return(config)
      Pra::PullSourceFactory.should_receive(:build_pull_source).with(pull_source_config_one)
      Pra::PullSourceFactory.should_receive(:build_pull_source).with(pull_source_config_two)
      subject.map_config_to_pull_sources
    end

    it "returns an array of the constructed PullSource based objects" do
      pull_source_one = double('pull source one')
      pull_source_two = double('pull source two')
      pull_source_config_one = double('pull source config one')
      pull_source_config_two = double('pull source config two')
      config = double('config', pull_sources: [pull_source_config_one, pull_source_config_two])
      Pra.stub(:config).and_return(config)
      Pra::PullSourceFactory.stub(:build_pull_source).with(pull_source_config_one).and_return(pull_source_one)
      Pra::PullSourceFactory.stub(:build_pull_source).with(pull_source_config_two).and_return(pull_source_two)
      subject.map_config_to_pull_sources.should eq([pull_source_one, pull_source_two])
    end
  end
end
