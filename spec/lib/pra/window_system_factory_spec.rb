require_relative '../../../lib/pra/window_system_factory'

describe Pra::WindowSystemFactory do
  describe ".build" do
    it "constructs a CursesWindowSystem given a curses window system id 'curses'" do
      expect(subject.build('curses')).to be_a(Pra::CursesWindowSystem)
    end

    it "raises an exception when given an window system id it doesn't understand" do
      expect{ subject.build('some_unknown_window_system_id') }.to raise_error(Pra::WindowSystemFactory::UnknownWindowSystemId)
    end
  end
end
