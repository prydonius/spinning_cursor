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
  #
  # This class contains the cursor types (and their helper methods)
  #
  class Cursor
    include SpinningCursor::ConsoleHelpers
    attr_accessor :banner, :output

    #
    # As of v0.1.0: only initializes the cursor class, use the spin
    # method to start the printing. Takes only the banner argument as
    # a result of this.
    #
    def initialize(banner = "Loading")
      @banner = banner
    end

    #
    # Takes a cursor type symbol and delay, and starts the printing
    #
    def spin(type = :spinner, delay = nil, output_mode=:inline)
      $stdout.sync = true
      @output = output_mode
      $console.print @banner
      if delay.nil? then send type else send type, delay end
    end

    private

    #
    # Prints three dots and clears the line
    #
    def dots(delay = 1)
      cycle_through ['.', '..', '...', ''], delay
    end

    #
    # Cycles through '|', '/', '-', '\', resembling a spinning cursor
    #
    def spinner(delay = 0.5)
      cycle_through ['|', '/', '-', '\\'], delay
    end

    def cycle_through(chars, delay)
      chars.cycle do |char|
        unless @output==:at_stop or captured_console_empty?
          $console.print "#{ESC_R_AND_CLR}"
          $console.print $stdout.string
          $console.print "\n" unless $stdout.string[-1,1] == "\n"
          $stdout.string = "" # TODO: Check for race condition.
        end
        $console.print "#{ESC_R_AND_CLR}#{@banner}"
        $console.print " " unless @banner.empty?
        $console.print "#{char}"
        sleep delay
      end
    end
  end
end
