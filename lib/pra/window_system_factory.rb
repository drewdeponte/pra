require 'pra/curses_window_system'

module Pra
  module WindowSystemFactory
    class UnknownWindowSystemId < RuntimeError; end

    def self.build(window_system_id)
      case window_system_id
      when 'curses'
        return Pra::CursesWindowSystem.new
      else
        raise Pra::WindowSystemFactory::UnknownWindowSystemId, ".build() doesn't know about a windows system identified by '#{window_system_id}'"
      end
    end
  end
end
