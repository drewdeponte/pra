require 'clipuller/window_system'
require 'launchy'
require 'curses'

module Clipuller
  class CursesWindowSystem < Clipuller::WindowSystem
    def initialize
      @selected_pull_request_index = 0
      @current_pull_requests = []
    end

    def setup
      initialize_screen_settings
      display_instructions
      output_string(3, 0, "0 Pull Requests")
    end

    def fetching_pull_requests
      output_string(3, 0, "Fetching pull requests...")
    end

    def refresh_pull_requests(pull_requests)
      @current_pull_requests = pull_requests.dup
      draw_current_pull_requests
    end

    def run_loop
      c = Curses.getch()
      while c != 'q' do
        case c
        when 'j'
          move_selection_down
          draw_current_pull_requests
        when 'k'
          move_selection_up
          draw_current_pull_requests
        when 'o'
          Launchy.open(@current_pull_requests[@selected_pull_request_index].link)
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
    
    def output_string(row, col, str)
      Curses.setpos(row, col)
      Curses.clrtoeol
      Curses.addstr(str)
      Curses.refresh
    end

    def output_highlighted_string(row, col, str)
      Curses.attron(Curses.color_pair(1)|Curses::A_NORMAL) {
        output_string(row, col, str)
      }
    end

    def display_instructions
      output_string(0, 0, "Clipuller: Helping you own pull requests")
      output_string(1, 0, "quit: q, up: k, down: j, open: o")
    end

    def move_selection_up
      if @selected_pull_request_index > 0
        @selected_pull_request_index -= 1
      end
    end

    def move_selection_down
      if @selected_pull_request_index < @current_pull_requests.length
        @selected_pull_request_index += 1
      end
    end

    def draw_current_pull_requests
      output_string(3, 0, "#{@current_pull_requests.length} Pull Requests")
      output_string(5, 0, "   title                        from_reference          to_reference            author")
      output_string(6, 0, "---------------------------------------------------------------------------------------------------")
      @current_pull_requests.each_with_index do |pull_request, index|
        if index == @selected_pull_request_index
          output_highlighted_string(7 + index, 0, "#{index}: #{pull_request.title.ljust(20)[0..20]}\t#{pull_request.from_reference.ljust(20)[0..20]}\t#{pull_request.to_reference.ljust(20)[0..20]}\t#{pull_request.author.ljust(20)[0..20]}\t#{pull_request.service_id}\t#{pull_request.repository}")
        else
          output_string(7 + index, 0, "#{index}: #{pull_request.title.ljust(20)[0..20]}\t#{pull_request.from_reference.ljust(20)[0..20]}\t#{pull_request.to_reference.ljust(20)[0..20]}\t#{pull_request.author.ljust(20)[0..20]}\t#{pull_request.service_id}\t#{pull_request.repository}")
        end
      end
    end
  end
end
