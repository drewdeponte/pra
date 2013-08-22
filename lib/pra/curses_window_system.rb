require 'pra/window_system'
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
      @state_lock = Mutex.new
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
      @previous_number_of_pull_requests = @current_pull_requests.length

      @state_lock.synchronize {
        @current_pull_requests = pull_requests.dup
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
      Curses.curs_set(0)
      Curses.init_pair(1, Curses::COLOR_CYAN, Curses::COLOR_BLACK)
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

    def draw_current_pull_requests
      @state_lock.synchronize {
        output_string(3, 0, "#{@current_pull_requests.length} Pull Requests")
        output_string(5, 0, "repository      title                   from_reference          to_reference            author                  service")
        output_string(6, 0, "--------------------------------------------------------------------------------------------------------------------------------")
        
        (7...7+@previous_number_of_pull_requests).each do |i|
          Curses.setpos(i,0)
          Curses.clrtoeol
          Curses.refresh
        end

        @current_pull_requests.each_with_index do |pull_request, index|
          if index == @selected_pull_request_index
            output_highlighted_string(7 + index, 0, "#{pull_request.repository.ljust(15)[0..14]}\t#{pull_request.title.ljust(20)[0..19]}\t#{pull_request.from_reference.ljust(20)[0..19]}\t#{pull_request.to_reference.ljust(20)[0..19]}\t#{pull_request.author.ljust(20)[0..19]}\t#{pull_request.service_id.ljust(10)[0..9]}")
          else
            output_string(7 + index, 0, "#{pull_request.repository.ljust(15)[0..14]}\t#{pull_request.title.ljust(20)[0..19]}\t#{pull_request.from_reference.ljust(20)[0..19]}\t#{pull_request.to_reference.ljust(20)[0..19]}\t#{pull_request.author.ljust(20)[0..19]}\t#{pull_request.service_id.ljust(10)[0..9]}")
          end
        end
      }
    end
  end
end
