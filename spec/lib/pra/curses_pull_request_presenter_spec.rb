require_relative '../../../lib/pra/curses_pull_request_presenter'

describe Pra::CursesPullRequestPresenter do
  describe '.new' do
    it 'construct given pull request' do
      pull_request = double('pull request')
      Pra::CursesPullRequestPresenter.new(pull_request)
    end

    it 'assigns pull request to an instance variable' do
      pull_request = double('pull request')
      curses_pull_request = Pra::CursesPullRequestPresenter.new(pull_request)
      expect(curses_pull_request.instance_variable_get(:@pull_request)).to eq pull_request
    end
  end

  describe '#force_length' do
    it 'right pads the given string up to the specified length' do
      pull_request = double
      curses_pull_request = Pra::CursesPullRequestPresenter.new(pull_request)
      expect(curses_pull_request.send(:force_length, 'capture_api', 15)).to eq 'capture_api    '
    end

    it 'truncates the given string down to the specified length' do
      pull_request = double
      curses_pull_request = Pra::CursesPullRequestPresenter.new(pull_request)
      expect(curses_pull_request.send(:force_length, 'capture_api_012345678912345', 15)).to eq 'capture_api_012'
    end
  end

  describe '#repository' do
    it 'forces the repository length to 15' do
      repository = double
      curses_pull_request = Pra::CursesPullRequestPresenter.new(double('pull request', repository: repository))
      expect(curses_pull_request).to receive(:force_length).with(repository, 15)
      curses_pull_request.repository
    end
  end

  describe '#title' do
    it 'forces the title length to 20' do
      title = double
      curses_pull_request = Pra::CursesPullRequestPresenter.new(double('pull request', title: title))
      expect(curses_pull_request).to receive(:force_length).with(title, 20)
      curses_pull_request.title
    end
  end

  describe '#from_reference' do
    it 'forces the from_reference length to 20' do
      from_reference = double
      curses_pull_request = Pra::CursesPullRequestPresenter.new(double('pull request', from_reference: from_reference))
      expect(curses_pull_request).to receive(:force_length).with(from_reference, 20)
      curses_pull_request.from_reference
    end
  end

  describe '#to_reference' do
    it 'forces the to_reference length to 20' do
      to_reference = double
      curses_pull_request = Pra::CursesPullRequestPresenter.new(double('pull request', to_reference: to_reference))
      expect(curses_pull_request).to receive(:force_length).with(to_reference, 20)
      curses_pull_request.to_reference
    end
  end

  describe '#author' do
    it 'forces the author length to 20' do
      author = double
      curses_pull_request = Pra::CursesPullRequestPresenter.new(double('pull request', author: author))
      expect(curses_pull_request).to receive(:force_length).with(author, 20)
      curses_pull_request.author
    end
  end

  describe '#assignee' do
    context 'when assignee is nil' do
      it 'returns an empty string with length of 20' do
        curses_pull_request = Pra::CursesPullRequestPresenter.new(double('pull_request', assignee: nil))
        expect(curses_pull_request.assignee).to eq(' '*20)
      end
    end

    context 'when assignee is NOT nil' do
      context 'when assignee is blacklisted' do
        it 'returns an empty string with length of 20' do
          curses_pull_request = Pra::CursesPullRequestPresenter.new(double('pull_request', assignee: nil))
          expect(curses_pull_request.assignee).to eq(' '*20)
        end
      end
    end

    context 'when assignee is NOT blacklisted' do
      it 'returns assignee with a length of 20' do
        curses_pull_request = Pra::CursesPullRequestPresenter.new(double('pull_request', assignee: 'IPT-Capture'))
        allow(curses_pull_request).to receive(:assignee_blacklist).and_return(['IPT'])
        expect(curses_pull_request.assignee).to eq('IPT-Capture         ')
      end
    end

    context 'when assignee IS blacklisted' do
      it 'returns an empty string with length of 20' do
        curses_pull_request = Pra::CursesPullRequestPresenter.new(double('pull_request', assignee: 'IPT-Capture'))
        allow(curses_pull_request).to receive(:assignee_blacklist).and_return(['IPT-Capture'])
        expect(curses_pull_request.assignee).to eq(' '*20)
      end
    end
  end

  describe '#service_id' do
    it 'forces the service_id length to 20' do
      service_id = double
      curses_pull_request = Pra::CursesPullRequestPresenter.new(double('pull request', service_id: service_id))
      expect(curses_pull_request).to receive(:force_length).with(service_id, 10)
      curses_pull_request.service_id
    end
  end

  describe '#to_s' do
    it 'returns a string representing the pull request for curses' do
      pull_request = double('pull request', repository: 'some repo',
                            title: 'some title', author: 'some author',
                            assignee: 'some assignee', labels: 'some labels',
                            service_id: 'some service id')
      presenter = Pra::CursesPullRequestPresenter.new(pull_request)
      expect(presenter.to_s).to eq("some repo           \tsome title                              \tsome author   \tsome assignee \tsome labels \tsome ser")
    end
  end

  describe '#blacklisted?' do
    context 'when assignee IS blacklisted' do
      it 'returns true' do
        curses_pull_request = Pra::CursesPullRequestPresenter.new(double('pull request', assignee: 'IPT-Capture'))
        allow(curses_pull_request).to receive(:assignee_blacklist).and_return(['IPT-Capture'])
        expect(curses_pull_request.send(:blacklisted?, 'IPT-Capture')).to eq true
      end
    end

    context 'when assignee IS not blacklisted' do
      it 'returns false' do
        curses_pull_request = Pra::CursesPullRequestPresenter.new(double('pull request', assignee: 'IPT-Capture'))
        allow(curses_pull_request).to receive(:assignee_blacklist).and_return(['IPT'])
        expect(curses_pull_request.send(:blacklisted?, 'IPT-Capture')).to eq false
      end
    end
  end
end
