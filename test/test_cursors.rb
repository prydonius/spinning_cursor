require 'helper'

class TestSpinningCursorCursor < Test::Unit::TestCase
  context "dots" do
    should "reset line after printing three dots" do
      capture_stdout do |out|
        dots = Thread.new do
          SpinningCursor::Cursor.new("").spin :dots, 0.2
        end
        # "." -> ".." -> "..." -> "" -> "." -- so 1 seconds for each cycle
        sleep 1
        dots.kill
        # \r\e[0K is move cursor to the start of the line and clear line
        # in bash
        assert_equal ".\r\e[0K..\r\e[0K...\r\e[0K\r\e[0K.", out.string
      end
    end

    should "change 'frames' with correct delay" do
      capture_stdout do |out|
        dots = Thread.new do
          SpinningCursor::Cursor.new("").spin :dots, 0.5
        end
        # slight delay to get things started
        sleep 0.1
        assert_equal ".", out.string
        sleep 0.5
        assert_equal ".\r\e[0K..", out.string
        # don't need to go through the whole thing, otherwise test will take
        # too long
        dots.kill
      end
    end
  end

  context "spinner" do
    should "cycle through correctly" do
      capture_stdout do |out|
        spinner = Thread.new do
          SpinningCursor::Cursor.new("").spin :spinner, 0.2
        end
        # slight delay to get things started
        sleep 0.1
        assert_equal "|", out.string
        buffer = "|\r\e[0K"
        sleep 0.2
        assert_equal "#{buffer}/", out.string
        buffer += "/\r\e[0K"
        sleep 0.2
        assert_equal "#{buffer}-", out.string
        buffer += "-\r\e[0K"
        sleep 0.2
        assert_equal "#{buffer}\\", out.string
        buffer += "\\\r\e[0K"
        sleep 0.2
        assert_equal "#{buffer}|", out.string
        spinner.kill
      end
    end

    should "changes 'frames' with correct delay" do
      capture_stdout do |out|
        spinner = Thread.new do
          SpinningCursor::Cursor.new("").spin :spinner, 0.5 # 4x the speed
        end
        sleep 0.1
        assert_equal "|", out.string
        buffer = "|\r\e[0K"
        sleep 0.5
        # next frame after 0.5 second
        assert_equal "#{buffer}/", out.string
        # don't need to go through the whole thing, otherwise test will take
        # too long
        spinner.kill
      end
    end
  end
end
