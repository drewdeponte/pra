require 'clipuller/window_system'
require 'curses'

module Clipuller
  class CursesWindowSystem < Clipuller::WindowSystem
    def setup
      initialize_screen_settings
      display_instructions
    end

    def refresh_pull_requests(pull_requests)
      puts "got pull requests, #{pull_requests.inspect}"
    end

    def run_loop
      c = Curses.getch()
      while c != 'q' do
        Curses.setpos(2, 0)
        Curses.clrtoeol
        Curses.addstr("You pressed #{c}")
        Curses.refresh

        case c
        when 'j'
        when 'k'
        when 'o'
        end
        c = Curses.getch()
      end

      Curses.close_screen
    end

    private

    def initialize_screen_settings
      Curses.noecho # do not show typed keys
      Curses.init_screen
      Curses.start_color
      Curses.curs_set(0)
      Curses.init_pair(1, Curses::COLOR_CYAN, Curses::COLOR_BLACK)
      Curses.nl
    end

    def display_instructions
      Curses.setpos(0, 0)
      Curses.clrtoeol
      Curses.addstr("Clipuller: Helping you own pull requests")
      Curses.setpos(1, 0)
      Curses.clrtoeol
      Curses.addstr("quit: q, up: k | Up Arrow, down: j | Down Arrow, open: o | Enter")
      Curses.refresh
    end
  end
end
