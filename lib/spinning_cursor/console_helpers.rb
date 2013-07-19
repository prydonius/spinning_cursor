require 'stringio'
require 'curses'

$console = STDOUT

module SpinningCursor
  module ConsoleHelpers
    if RUBY_PLATFORM =~ /(win|w)32$/
      # DOS
      # Contains a string to clear the line in the shell
      CLR = "                                                               \r"
    else
      # Unix
      # Contains a string to clear the line in the shell
      CLR = "\e[0K"
    end

    # ANSI escape sequence for hiding terminal cursor
    ESC_CURS_INVIS = "\e[?25l"
    # ANSI escape sequence for showing terminal cursor
    ESC_CURS_VIS   = "\e[?25h"
    # ANSI escape sequence for clearing line in terminal
    ESC_R_AND_CLR  = "\r#{CLR}"
    # ANSI escape sequence for going up a line in terminal
    ESC_UP_A_LINE  = "\e[1A"

    @@prev = 0

    #
    # Manages line reset in the console
    #
    def reset_line(text = "")
      # Initialise ANSI escape string
      escape = ""

      # Get terminal window width
      cols = console_columns

      # The number of lines the previous message spanned
      lines = @@prev / cols

      # If cols == 80 and @@prev == 80, @@prev / cols == 1 but we don't want to
      # go up an extra line since it fits exactly
      lines -= 1 if @@prev % cols == 0

      # Clear and go up a line
      lines.times { escape += "#{ESC_R_AND_CLR}#{ESC_UP_A_LINE}" }

      # Clear the line that is to be printed on
      escape += "#{ESC_R_AND_CLR}"

      # Console is clear, we can print!
      $console.print "#{escape}#{text}"

      # Store the current message so we know how many lines it spans
      @@prev = text.to_s.length
    end

    #
    # Stores current `STDOUT.sync` value and sets it to true
    #
    def save_stdout_sync_status
      @stdout_sync_saved_status = STDOUT.sync
      STDOUT.sync = true
    end

    #
    # Restores the previously stored `STDOUT.sync` value
    #
    def restore_stdout_sync_status
      STDOUT.sync = @stdout_sync_saved_status
    end

    #
    # Sets `$stdout` global variable to a `StringIO` object to buffer output
    #
    def capture_console
      $stdout = StringIO.new
    end

    #
    # Resets `$stdout` global variable to `STDOUT`
    #
    def release_console
      $stdout = $console
    end

    #
    # Returns true if `$stdout` is a `StringIO` object
    #
    def console_captured?
      $stdout.is_a?(StringIO)
    end

    #
    # Returns true if the output buffer is currently empty
    #
    def captured_console_empty?
      console_captured? and $stdout.string.empty?
    end

    #
    # Hides the terminal cursor
    #
    def hide_cursor
      $console.print ESC_CURS_INVIS
    end

    #
    # Shows the terminal cursor
    #
    def show_cursor
      $console.print ESC_CURS_VIS
    end

    #
    # Returns the width of the terminal window
    #
    def console_columns
      Curses.init_screen
      cols = Curses.cols
      Curses.close_screen

      cols
    end
  end
end
