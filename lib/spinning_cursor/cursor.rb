module SpinningCursor
  #
  # This class contains the cursor types (and their helper methods)
  #
  class Cursor
    include SpinningCursor::ConsoleHelpers

    #
    # As of v0.1.0: only initializes the cursor class, use the spin
    # method to start the printing. Takes only the banner argument as
    # a result of this.
    #
    def initialize(parsed)
      @parsed = parsed
    end

    #
    # Takes a cursor type symbol and delay, and starts the printing
    #
    def spin
      $stdout.sync = true
      $console.print @parsed.banner
      if @parsed.delay
        send @parsed.type, @parsed.delay
      else
        send @parsed.type
      end
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
        unless @parsed.output==:at_stop or captured_console_empty?
          $console.print "#{ESC_R_AND_CLR}"
          $console.print $stdout.string
          $console.print "\n" unless $stdout.string[-1,1] == "\n"
          $stdout.string = "" # TODO: Check for race condition.
        end
        $console.print "#{ESC_R_AND_CLR}#{@parsed.banner}"
        $console.print " " unless @parsed.banner.empty?
        $console.print "#{char}"
        sleep delay
      end
    end
  end
end
