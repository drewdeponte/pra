require 'pra/pull_request_service/fetch_status'

describe Pra::PullRequestService::FetchStatus do
  describe '.new' do
    it 'assigns the status' do
      status = double
      fetch = Pra::PullRequestService::FetchStatus.new(status, double)
      expect(fetch.status).to eq(status)
    end

    it 'assigns the pull requests' do
      pulls = [double]
      fetch = Pra::PullRequestService::FetchStatus.new(double, pulls)
      expect(fetch.pull_requests).to eq(pulls)
    end

    it 'assigns the error' do
      error = double
      fetch = Pra::PullRequestService::FetchStatus.new(double, double, error)
      expect(fetch.error).to eq(error)
    end
  end

  describe '.success' do
    let(:pulls) { double }
    subject { Pra::PullRequestService::FetchStatus.success(pulls) }

    it 'sets the status to success' do
      expect(subject.status).to eq(:success)
    end

    it 'assigns the pull requests' do
      expect(subject.pull_requests).to eq(pulls)
    end
  end

  describe '.error' do
    let(:error) { double }
    subject { Pra::PullRequestService::FetchStatus.error(error) }

    it 'sets the status to error' do
      expect(subject.status).to eq(:error)
    end

    it 'sets the pull requests to a dummy value' do
      expect(subject.pull_requests).to eq(:no_pull_requests)
    end
  end

  describe '#success?' do
    context 'when status is :success' do
      subject { Pra::PullRequestService::FetchStatus.new(:success, double) }

      it 'returns true' do
        expect(subject.success?).to be_true
      end
    end

    context 'when status is not :success' do
      subject { Pra::PullRequestService::FetchStatus.new(double, double) }

      it 'returns false' do
        expect(subject.success?).to be_false
      end
    end
  end

  describe '#error?' do
    context 'when status is :error' do
      subject { Pra::PullRequestService::FetchStatus.new(:error, double) }

      it 'returns true' do
        expect(subject.error?).to be_true
      end
    end

    context 'when status is not :error' do
      subject { Pra::PullRequestService::FetchStatus.new(double, double) }

      it 'returns false' do
        expect(subject.error?).to be_false
      end
    end
  end

  describe '#on_success' do
    let(:pulls) { double }
    let(:error) { double }

    context 'when status is success' do
      subject { Pra::PullRequestService::FetchStatus.success(pulls) }

      it 'yields the pull requests to the block' do
        expect { |success_block| subject.on_success(&success_block) }.to yield_with_args(pulls)
      end
    end

    context 'when status is not success' do
      subject { Pra::PullRequestService::FetchStatus.error(double) }

      it 'does not yield' do
        expect {|success_block| subject.on_success(&success_block) }.not_to yield_control
      end
    end
  end

  describe '#on_error' do
    let(:pulls) { double }
    let(:error) { double }

    context 'when status is error' do
      subject { Pra::PullRequestService::FetchStatus.error(error) }

      it 'yields the error to the block' do
        expect { |error_block| subject.on_error(&error_block) }.to yield_with_args(error)
      end
    end

    context 'when status is not error' do
      subject { Pra::PullRequestService::FetchStatus.success(double) }

      it 'does not yield' do
        expect {|error_block| subject.on_error(&error_block) }.not_to yield_control
      end
    end
  end
end