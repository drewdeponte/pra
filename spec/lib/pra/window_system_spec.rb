require_relative "../../../lib/pra/window_system"

describe Pra::WindowSystem do
  describe "#setup" do
    it "raises a message stating that the pure virtual method has not been implemented" do
      expect { subject.setup }.to raise_error(Pra::WindowSystem::PureVirtualMethodNotImplemented)
    end
  end

  describe "#fetching_pull_requests" do
    it "raises a message stating that the pure virtual method has not been implemented" do
      expect { subject.fetching_pull_requests }.to raise_error(Pra::WindowSystem::PureVirtualMethodNotImplemented)
    end
  end

  describe "#refresh_pull_requests" do
    it "raises a message stating that the pure virtual method has not been implemented" do
      expect { subject.refresh_pull_requests(double('pull requests')) }.to raise_error(Pra::WindowSystem::PureVirtualMethodNotImplemented)
    end
  end

  describe "#run_loop" do
    it "raises a message stating that the pure virtual method has not been implemented" do
      expect { subject.run_loop }.to raise_error(Pra::WindowSystem::PureVirtualMethodNotImplemented)
    end
  end
end
