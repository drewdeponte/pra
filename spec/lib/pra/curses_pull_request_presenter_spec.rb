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

  describe '#assignee' do
    context 'when assignee is nil' do
      it 'returns an empty string' do
        curses_pull_request = Pra::CursesPullRequestPresenter.new(double('pull_request', assignee: nil))
        expect(curses_pull_request.assignee).to eq('')
      end
    end

    context 'when assignee is NOT nil' do
      context 'when assignee is blacklisted' do
        it 'returns an empty string' do
          curses_pull_request = Pra::CursesPullRequestPresenter.new(double('pull_request', assignee: nil))
          expect(curses_pull_request.assignee).to eq('')
        end
      end
    end

    context 'when assignee is NOT blacklisted' do
      it 'returns assignee' do
        curses_pull_request = Pra::CursesPullRequestPresenter.new(double('pull_request', assignee: 'IPT-Capture'))
        allow(curses_pull_request).to receive(:assignee_blacklist).and_return(['IPT'])
        expect(curses_pull_request.assignee).to eq('IPT-Capture')
      end
    end

    context 'when assignee IS blacklisted' do
      it 'returns an empty string' do
        curses_pull_request = Pra::CursesPullRequestPresenter.new(double('pull_request', assignee: 'IPT-Capture'))
        allow(curses_pull_request).to receive(:assignee_blacklist).and_return(['IPT-Capture'])
        expect(curses_pull_request.assignee).to eq('')
      end
    end
  end

  describe '#present' do
    it 'returns a string representing the pull request for curses from column format' do
      pull_request = double('pull request', repository: 'some repo',
                            title: 'some title', author: 'some author',
                            assignee: 'some assignee', labels: 'some labels',
                            service_id: 'some service id')
      columns = [
        { name: :repository, size: 28, padding: 2 },
        { name: :title, size: 45, padding: 2 },
        { name: :author, size: 14, padding: 2 },
        { name: :assignee, size: 14, padding: 2 },
        { name: :labels, size: 12, padding: 2 }
      ]
      presenter = Pra::CursesPullRequestPresenter.new(pull_request)
      allow(presenter).to receive(:assignee_blacklist).and_return(['IPT'])
      expect(presenter.present(columns)).to eq("some repo                     some title                                     some author     some assignee   some labels   ")
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
