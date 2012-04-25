require 'helper'

class TestSpinningCursor < Test::Unit::TestCase
  context "API" do
    should "raise CursorNotRunning error for set_message, set_banner, and 
      stop methods" do
      assert_raise SpinningCursor::CursorNotRunning do
        SpinningCursor.set_message "Hi!"
      end

      assert_raise SpinningCursor::CursorNotRunning do
        SpinningCursor.set_banner "Hi!"
      end

      assert_raise SpinningCursor::CursorNotRunning do
        SpinningCursor.stop
      end
    end

    should "a) raise NoTaskError when getting execution time if no task ran" do
      assert_raise SpinningCursor::NoTaskError do
        SpinningCursor.get_exec_time
      end
    end

    should "raise CursorNotRunning errors when cursor has run and finished" do
      SpinningCursor.start
      SpinningCursor.stop
      assert_raise SpinningCursor::CursorNotRunning do
        SpinningCursor.set_message "Hi!"
      end

      assert_raise SpinningCursor::CursorNotRunning do
        SpinningCursor.set_banner "Hi!"
      end

      assert_raise SpinningCursor::CursorNotRunning do
        SpinningCursor.stop
      end
    end
  end
end