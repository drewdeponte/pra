require 'pra/window_system'
require 'pra/curses_pull_request_presenter'
require 'pra/config'
require 'launchy'
require 'curses'
require 'thread'

module Pra
  class CursesWindowSystem < Pra::WindowSystem
    ENTER_KEY = 10
    ESC_KEY = 27
    BACKSPACE_KEY = 127

    def initialize
      @selected_pull_request_page_index = 0
      @current_page = 1
      @current_pull_requests = []
      @previous_number_of_pull_requests = 0
      @last_updated = nil
      @state_lock = Mutex.new
      @last_updated_access_lock = Mutex.new
      @force_update = true
      @force_update_access_lock = Mutex.new
      @filter_mode = false
      @filter_string = ""
    end

    def last_updated
      current_last_updated = nil
      @last_updated_access_lock.synchronize {
        current_last_updated = @last_updated.dup
      }
      current_last_updated
    end

    def force_refresh
      do_force_update = false
      @force_update_access_lock.synchronize {
        do_force_update = @force_update
      }
      do_force_update
    end

    def force_refresh=(force_update)
      @force_update_access_lock.synchronize {
        @force_update = force_update
      }
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
      output_string(4, 0, "Failed to fetch pull requests on 1 or more pull sources. Check #{Pra::Config.log_path} for details.")
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
        if @filter_mode
          case c
          when ESC_KEY
            @filter_mode = false
            @filter_string = ""
            Curses.setpos(5, 0)
            Curses.clrtoeol
            @current_pull_requests = @original_pull_requests.dup
            @original_pull_requests = nil
            draw_current_pull_requests
          when ENTER_KEY
            @filter_mode = false
            @filter_string = ""
          when "\b", BACKSPACE_KEY, Curses::KEY_BACKSPACE
            @filter_string.chop!
            output_string(5, 0, "Filter: #{@filter_string}")
            clear_pull_requests
            filter_current_pull_requests(@filter_string)
          when String
            @filter_string += c
            output_string(5, 0, "Filter: #{@filter_string}")
            clear_pull_requests
            filter_current_pull_requests(@filter_string)
          end
        else
          case c
          when 'j', Curses::Key::DOWN
            move_selection_down
            draw_current_pull_requests
          when 'k', Curses::Key::UP
            move_selection_up
            draw_current_pull_requests
          when 'r'
            @force_update = true
            Curses.setpos(5, 0)
            Curses.clrtoeol
          when 'o', ENTER_KEY
            @state_lock.synchronize {
              Launchy.open(@current_pull_requests[selected_pull_request_loc].link)
            }
          when 'n'
            load_next_page
          when 'p'
            load_prev_page
          when '/'
            @filter_mode = true
            @original_pull_requests = @current_pull_requests.dup
            output_string(5, 0, "Filter: #{@filter_string}")
          end
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
      Curses.attron(Curses::A_REVERSE) {
        output_string(row, col, str)
      }
    end

    def display_instructions
      output_string(0, 0, "Pra: Helping you own pull requests")
      output_string(1, 0, "quit: q, up: k|#{"\u25B2".encode("UTF-8")}, down: j|#{"\u25BC".encode("UTF-8")}, open: o|#{"\u21A9".encode("UTF-8")}, refresh: r, next page: n, prev page: p, filter: /")
    end

    def move_selection_up
      @state_lock.synchronize {
        if @selected_pull_request_page_index > 0
          @selected_pull_request_page_index -= 1
        end
      }
    end

    def move_selection_down
      @state_lock.synchronize {
        if selected_pull_request_loc < @current_pull_requests.length - 1 &&
          (LIST_START_LINE + @selected_pull_request_page_index + 1) < Curses.lines
          @selected_pull_request_page_index += 1
        end
      }
    end

    def selected_pull_request_loc
      (@current_page - 1) * pull_requests_per_page + @selected_pull_request_page_index
    end

    HEADER_LINE = 6
    LIST_START_LINE = HEADER_LINE + 2

    def columns
      [
        { name: :repository, size: 28, padding: 2 },
        { name: :title, size: 45, padding: 2 },
        { name: :author, size: 14, padding: 2 },
        { name: :assignee, size: 14, padding: 2 },
        { name: :labels, size: 12, padding: 2 },
        { name: :updated_at, size: 16, padding: 2 }
      ]
    end

    def header_width
      @header_width ||= columns.reduce(0) do |t,c|
        c[:size] + c[:padding] + t
      end
    end

    def headers
      header = ""
      columns.each do |column|
        header << "#{column[:name]}"
        header << (" " * (column[:size] - column[:name].length))
        header << " " * column[:padding]
      end

      header
    end

    def load_next_page
      if @current_page + 1 <= pull_request_pages
        @current_page += 1
        clear_pull_requests
        @selected_pull_request_page_index = 0
        draw_current_pull_requests
      end
    end

    def load_prev_page
      if @current_page - 1 > 0
        @current_page -= 1
        clear_pull_requests
        @selected_pull_request_page_index = 0
        draw_current_pull_requests
      end
    end

    def pull_requests_per_page
      Curses.lines - LIST_START_LINE
    end

    def pull_request_pages
      (@current_pull_requests.length.to_f/pull_requests_per_page).ceil
    end

    def clear_pull_requests
      (LIST_START_LINE..Curses.lines).each do |i|
        Curses.setpos(i, 0)
        Curses.clrtoeol
      end
      Curses.refresh
    end

    def filter_current_pull_requests(input_string)
      pull_reqs = @original_pull_requests.dup.keep_if do |pr|
        columns.any? do |col|
          presenter = Pra::CursesPullRequestPresenter.new(pr)
          pr_attr_value = presenter.send(col[:name])
          if input_string == input_string.downcase
            pr_attr_value.to_s.downcase.include?(input_string)
          else
            pr_attr_value.to_s.include?(input_string)
          end
        end
      end

      refresh_pull_requests(pull_reqs)
    end

    def draw_current_pull_requests
      @state_lock.synchronize {
        output_string(3, 0, "#{@current_pull_requests.length} Pull Requests @ #{@last_updated} : Page #{@current_page} of #{pull_request_pages}")
        output_string(HEADER_LINE, 0, headers)
        output_string(HEADER_LINE + 1, 0, "-" * header_width)

        # clear lines that should no longer exist
        if @previous_number_of_pull_requests > @current_pull_requests.length
          start_line_of_left_overs = LIST_START_LINE+@current_pull_requests.length
          (start_line_of_left_overs..Curses.lines).each do |i|
            Curses.setpos(i, 0)
            Curses.clrtoeol
          end
          Curses.refresh
        end

        # go through and redraw all the pull requests
        @current_pull_requests[(@current_page-1)*pull_requests_per_page..@current_page*pull_requests_per_page-1].each_with_index do |pull_request, index|
          pull_request_presenter = Pra::CursesPullRequestPresenter.new(pull_request)
          if index == @selected_pull_request_page_index
            output_highlighted_string(LIST_START_LINE + index, 0, pull_request_presenter.present(columns))
          else
            output_string(LIST_START_LINE + index, 0, pull_request_presenter.present(columns))
          end
        end
      }
    end
  end
end
