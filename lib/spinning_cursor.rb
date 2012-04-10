require "spinning_cursor/cursor"
require "spinning_cursor/parser"

module SpinningCursor
  extend self

  #
  # Sends passed block to Parser, and starts cursor thread
  # It will execute the action block and kill the cursor
  # thread if an action block is passed.
  #
  def start(&block)
    if defined? @@curs
      if @@curs.alive?
        stop
      end
    end

    @@parsed = Parser.new(block)
    @@cursor = Cursor.new(@@parsed.banner nil)
    @@curs = Thread.new { @@cursor.spin(@@parsed.type nil) }

    # Time the execution
    @@start = Time.now

    if @@parsed.action.nil?
      return
    end
    # The action
    begin
      @@parsed.originator.instance_eval &@@parsed.action
    rescue
      set_message "Task failed..."
    ensure
      return stop
    end
  end

  #
  # Kills the cursor thread and prints the finished message
  # Returns execution time
  #
  def stop
    begin
      @@end = Time.now
      @@elapsed = @@end - @@start

      @@curs.kill
      reset_line
      puts (@@parsed.message nil)

      # Return execution time
      get_exec_time
    rescue NameError
      raise CursorNotRunning.new "Can't stop, no cursor running."
    end
  end

  #
  # Determines whether the cursor thread is still running
  #
  def alive?
    if not defined? @@curs
      return false
    else
      @@curs.alive?
    end
  end

  #
  # Sets the finish message (to be used inside the action for
  # non-deterministic output)
  #
  def set_message(msg)
    begin
      @@parsed.message msg
    rescue NameError
      raise CursorNotRunning.new "Cursor isn't running... are you sure " +
        "you're calling this from an action block?"
    end
  end

  #
  # Sets the banner message during execution
  #
  def set_banner(banner)
    begin
      @@cursor.banner = banner
    rescue NameError
      raise CursorNotRunning.new "Cursor isn't running... are you sure " +
        "you're calling this from an action block?"
    end
  end

  #
  # Retrieves execution time information
  #
  def get_exec_time
    begin
      return { :started => @@start, :finished => @@end,
        :elapsed => @@elapsed }
    rescue NameError
      raise NoTaskError.new "An execution hasn't started or finished."
    end
  end

  class NoTaskError < Exception ; end
  class CursorNotRunning < NoTaskError ; end
end