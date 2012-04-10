module SpinningCursor
  if RUBY_PLATFORM =~ /(win|w)32$/
    # Contains a string to clear the line in the shell
    CLR = "                                                               \r"
    # Haven't yet found a good solution for Windows...
  else
    # Unix
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
    #
    # Start the printing
    #
    def initialize(type = :spinner, banner = "Loading")
      @banner = banner
      $stdout.sync = true
      print @banner
      send type
    end

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