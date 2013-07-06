require "spinning_cursor/console_helpers"
require "spinning_cursor/cursor"
require "spinning_cursor/parser"
require "spinning_cursor/stop_watch"

module SpinningCursor
  extend self
  include self::ConsoleHelpers
  extend  self::ConsoleHelpers

  #
  # Sends passed block to Parser, and starts cursor thread
  # It will execute the action block and kill the cursor
  # thread if an action block is passed.
  #
  def start(&block)
    stop if alive?

    save_stdout_sync_status
    capture_console
    hide_cursor

    @parsed = Parser.new(&block)
    @cursor = Cursor.new(@parsed)
    @spinner = Thread.new do
      abort_on_exception = true
      @cursor.spin
    end

    @stop_watch = StopWatch.new

    if @parsed.action
      # The action
      begin
        @stop_watch.measure do
          @parsed.outer_scope_object.instance_eval &@parsed.action
        end
      rescue StandardError => e
        set_message "#{e.message}\n#{e.backtrace.join("\n")}"
        raise
      ensure
        stop
      end
    else
      # record start time
      @stop_watch.start
    end
  end

  #
  # Kills the cursor thread and prints the finished message
  # Returns execution time
  #
  def stop
    begin
      restore_stdout_sync_status
      if console_captured?
        $console.print ESC_R_AND_CLR + $stdout.string
        release_console
      end
      show_cursor

      @spinner.kill
      # Wait for the cursor to die -- can cause problems otherwise
      @spinner.join
      # Set cursor to nil so set_banner method only works
      # when cursor is actually running.
      @cursor = nil
      reset_line
      puts @parsed.message
      # Set parsed to nil so set_message method only works
      # when cursor is actually running.
      @parsed = nil

      # Return execution time
      @stop_watch.stop
      @stop_watch.timing
    rescue NameError
      raise CursorNotRunning.new "Can't stop, no cursor running."
    end
  end

  #
  # Determines whether the cursor thread is still running
  #
  def alive?
    @spinner and @spinner.alive?
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
      @parsed.banner banner
    rescue NameError
      raise CursorNotRunning.new "Cursor isn't running... are you sure " +
        "you're calling this from an action block?"
    end
  end

  private

  class NoTaskError < Exception ; end
  class CursorNotRunning < NoTaskError ; end
end
