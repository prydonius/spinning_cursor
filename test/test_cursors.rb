require 'helper'

class TestSpinningCursorCursor < Test::Unit::TestCase
  context "dots" do
    should "reset line after printing three dots" do
      capture_stdout do |out|
        dots = Thread.new do
          SpinningCursor::Cursor.new :dots, ""
        end
        sleep 5
        dots.kill
        # \r\e[0K is move cursor to the start of the line and clear line
        # in bash
        assert_equal "...\r\e[0K", out.string
      end
    end
  end

  context "spinner" do
    should "cycle through correctly" do
      capture_stdout do |out|
        spinner = Thread.new do
          SpinningCursor::Cursor.new :spinner, ""
        end
        sleep 0.1
        assert_equal "|", out.string
        buffer = "|\r\e[0K"
        sleep 0.5
        assert_equal "#{buffer}/", out.string
        buffer += "/\r\e[0K"
        sleep 0.5
        assert_equal "#{buffer}-", out.string
        buffer += "-\r\e[0K"
        sleep 0.5
        assert_equal "#{buffer}\\", out.string
        buffer += "\\\r\e[0K"
        sleep 0.5
        assert_equal "#{buffer}|", out.string
        spinner.kill
      end
    end
  end
end
