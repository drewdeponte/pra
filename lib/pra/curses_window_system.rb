require 'pra/window_system'
require 'pra/curses_pull_request_presenter'
require 'pra/config'
require 'launchy'
require 'curses'
require 'thread'

module Pra
  class CursesWindowSystem < Pra::WindowSystem
    ENTER_KEY = 10

    def initialize
      @selected_pull_request_index = 0
      @current_pull_requests = []
      @previous_number_of_pull_requests = 0
      @last_updated = nil
      @state_lock = Mutex.new
    end

    def setup
      initialize_screen_settings
      display_instructions
      output_string(3, 0, "0 Pull Requests")
    end

    def fetching_pull_requests
      output_string(3, 0, "Fetching pull requests...")
      Curses.setpos(4,0)
      Curses.clrtoeol
    end

    def fetch_failed
      output_string(4, 0, "Failed to fetch pull requests on 1 or more pull sources. Check #{Pra::Config.error_log_path} for details.")
    end

    def refresh_pull_requests(pull_requests)
      @previous_number_of_pull_requests = @current_pull_requests.length

      @state_lock.synchronize {
        @current_pull_requests = pull_requests.dup
        @last_updated = Time.now
      }
      draw_current_pull_requests
    end

    def run_loop
      c = Curses.getch()
      while (c != 'q') do
        case c
        when 'j', Curses::Key::DOWN
          move_selection_down
          draw_current_pull_requests
        when 'k', Curses::Key::UP
          move_selection_up
          draw_current_pull_requests
        when 'o', ENTER_KEY
          @state_lock.synchronize {
            Launchy.open(@current_pull_requests[@selected_pull_request_index].link)
          }
        end
        c = Curses.getch()
      end

      Curses.close_screen
    end

    private

    def initialize_screen_settings
      Curses.noecho # do not show typed keys
      Curses.init_screen
      Curses.stdscr.keypad(true)
      Curses.start_color
      Curses.use_default_colors
      Curses.curs_set(0)
      Curses.init_pair(Curses::COLOR_CYAN, Curses::COLOR_CYAN, Curses::COLOR_WHITE)
    end

    def output_string(row, col, str)
      Curses.setpos(row, col)
      Curses.clrtoeol
      Curses.addstr(str)
      Curses.refresh
    end

    def output_highlighted_string(row, col, str)
      Curses.attron(Curses.color_pair(Curses::COLOR_CYAN)|Curses::A_NORMAL) {
        output_string(row, col, str)
      }
    end

    def display_instructions
      output_string(0, 0, "Pra: Helping you own pull requests")
      output_string(1, 0, "quit: q, up: k|#{"\u25B2".encode("UTF-8")}, down: j|#{"\u25BC".encode("UTF-8")}, open: o|#{"\u21A9".encode("UTF-8")}")
    end

    def move_selection_up
      @state_lock.synchronize {
        if @selected_pull_request_index > 0
          @selected_pull_request_index -= 1
        end
      }
    end

    def move_selection_down
      @state_lock.synchronize {
        if @selected_pull_request_index < @current_pull_requests.length-1
          @selected_pull_request_index += 1
        end
      }
    end

    HEADER_LINE = 6
    LIST_START_LINE = HEADER_LINE + 2

    def draw_current_pull_requests
      @state_lock.synchronize {
        output_string(3, 0, "#{@current_pull_requests.length} Pull Requests @ #{@last_updated}")
        output_string(HEADER_LINE, 0, "repository              title                                           author          assignee       labels           updated at")
        output_string(HEADER_LINE + 1, 0, "---------------------------------------------------------------------------------------------------------------------------------------")

        # clear lines that should no longer exist
        if @previous_number_of_pull_requests > @current_pull_requests.length
          start_line_of_left_overs = LIST_START_LINE+@current_pull_requests.length
          last_line_of_left_overs = LIST_START_LINE+@previous_number_of_pull_requests + 1
          (start_line_of_left_overs..last_line_of_left_overs).each do |i|
            Curses.setpos(i, 0)
            Curses.clrtoeol
          end
          Curses.refresh
        end

        # go through and redraw all the pull requests
        @current_pull_requests.each_with_index do |pull_request, index|
          pull_request_presenter = Pra::CursesPullRequestPresenter.new(pull_request)
          if index == @selected_pull_request_index
            output_highlighted_string(LIST_START_LINE + index, 0, pull_request_presenter.to_s)
          else
            output_string(LIST_START_LINE + index, 0, pull_request_presenter.to_s)
          end
        end
      }
    end
  end
end
