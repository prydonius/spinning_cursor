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
    stop if alive?

    capture_console

    @parsed = Parser.new(block)
    @cursor = Cursor.new(@parsed.banner)
    @curs   = Thread.new { @cursor.spin(@parsed.type, @parsed.delay) }
    @curs.abort_on_exception = true
    @start  = @finish = @elapsed = nil

    if @parsed.action
      # The action
      begin
        do_exec_time do
          @parsed.originator.instance_eval &@parsed.action
        end
      rescue StandardError => e
        set_message "#{e.message}\n#{e.backtrace.join("\n")}"
      ensure
        return stop
      end
    else
      # record start time
      do_exec_time
    end
  end

  #
  # Kills the cursor thread and prints the finished message
  # Returns execution time
  #
  def stop
    begin
      release_console

      @curs.kill
      # Wait for the cursor to die -- can cause problems otherwise
      sleep(0.1) while @curs.alive?
      # Set cursor to nil so set_banner method only works
      # when cursor is actually running.
      @cursor = nil
      reset_line
      puts @parsed.message
      # Set parsed to nil so set_message method only works
      # when cursor is actually running.
      @parsed = nil

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
    @curs and @curs.alive?
  end

  #
  # Sets the finish message (to be used inside the action for
  # non-deterministic output)
  #
  def set_message(msg)
    begin
      @parsed.message msg
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
      @cursor.banner = banner
    rescue NameError
      raise CursorNotRunning.new "Cursor isn't running... are you sure " +
        "you're calling this from an action block?"
    end
  end

  #
  # Retrieves execution time information
  #
  def get_exec_time
    raise NoTaskError.new "An execution hasn't started or finished." unless @start
    do_exec_time unless @finish or @curs.alive?
    { :started => @start, :finished => @finish,
      :elapsed => @elapsed }
  end

  private

  #
  # Takes a block, and returns the start, finish and elapsed times
  #
  def do_exec_time
    if @curs.alive?
      @start = Time.now
      yield if block_given?
    end
    @finish = Time.now
    @elapsed = @finish - @start
  end

  class NoTaskError < Exception ; end
  class CursorNotRunning < NoTaskError ; end
end
