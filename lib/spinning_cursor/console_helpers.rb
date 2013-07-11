require 'stringio'

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

    ESC_CURS_INVIS = "\e[?25l"
    ESC_CURS_VIS   = "\e[?25h"
    ESC_R_AND_CLR  = "\r#{CLR}"

    #
    # Manages line reset in the console
    #
    def reset_line(text = "")
      $console.print "#{ESC_R_AND_CLR}#{text}"
    end

    def save_stdout_sync_status
      @stdout_sync_saved_status = STDOUT.sync
      STDOUT.sync = true
    end

    def restore_stdout_sync_status
      STDOUT.sync = @stdout_sync_saved_status
    end

    def capture_console
      $stdout = StringIO.new
    end

    def release_console
      $stdout = $console
    end

    def console_captured?
      $stdout.is_a?(StringIO)
    end

    def captured_console_empty?
      console_captured? and $stdout.string.empty?
    end

    def hide_cursor
      $console.print ESC_CURS_INVIS
    end

    def show_cursor
      $console.print ESC_CURS_VIS
    end
  end
end