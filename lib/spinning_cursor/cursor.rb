require 'stringio'

$console = STDOUT

module SpinningCursor
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
    $console.print "\r#{CLR}#{text}"
  end

  def capture_console
    $stdout = StringIO.new
  end

  def release_console
    $stdout = $console
  end

  def hide_cursor
    $console.print ESC_CURS_INVIS
  end

  def show_cursor
    $console.print ESC_CURS_VIS
  end

  #
  # This class contains the cursor types (and their helper methods)
  #
  class Cursor
    attr_accessor :banner

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
    def spin(type = :spinner, delay = nil)
      $stdout.sync = true
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
        unless $stdout.string.empty?
          $console.print "\r\e[0K"
          $console.print $stdout.string
          $console.print "\n" unless $stdout.string[-1] == "\n"
          $stdout.string = "" # TODO: Check for race condition.
        end
        $console.print "\r#{@banner}"
        $console.print " " unless @banner.empty?
        $console.print "#{char}"
        sleep delay
        #SpinningCursor.reset_line @banner
      end
    end
  end
end
