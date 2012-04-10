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
    @@curs = Thread.new {
      Cursor.new((@@parsed.type nil), (@@parsed.banner nil))
    }
    if @@parsed.action.nil?
      return
    end
    @@parsed.originator.instance_eval &@@parsed.action
    stop
  end

  #
  # Kills the cursor thread and prints the finished message
  #
  def stop
    @@curs.kill
    reset_line
    puts (@@parsed.message nil)
  end

  #
  # Determines whether the cursor thread is still running
  #
  def alive?
    @@curs.alive?
  end

  #
  # Sets the finish message (to be used inside the action for
  # non-deterministic output)
  #
  def set_message(msg)
    @@parsed.message msg
  end
end