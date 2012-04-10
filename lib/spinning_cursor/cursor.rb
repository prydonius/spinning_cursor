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

  #
  # Manages line reset in the console
  #
  def reset_line(text = "")
    print "\r#{CLR}#{text}"
  end

  #
  # This class contains the cursor types (and their helper methods)
  #
  class Cursor
    attr_accessor :banner

    #
    # As of v0.1.0: only initializes the cursor class, use the print
    # method to start the printing. Takes only the banner argument as
    # a result of this.
    #
    def initialize(banner = "Loading")
      @banner = banner
    end

    #
    # Takes a cursor type symbol and starts the printing
    #
    def spin(type = :spinner)
      $stdout.sync = true
      print @banner
      send type
    end

    private

    #
    # Prints three dots and clears the line
    #
    def dots
      i = 1
      loop do
        sleep 1
        if i % 4 == 0
          SpinningCursor.reset_line @banner
          i += 1
          next
        end
        i += 1
        print "."
      end
    end

    #
    # Cycles through '|', '/', '-', '\', resembling a spinning cursor
    #
    def spinner
      spinners = ['|', '/', '-', '\\']
      i = 0
      loop do
        print " " unless @banner.empty?
        print spinners[i % 4]
        sleep 0.5
        SpinningCursor.reset_line @banner
        i += 1
      end
    end
  end
end