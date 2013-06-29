require 'helper'

class TestSpinningCursorCursor < Test::Unit::TestCase
  delay = 0.2
  context "dots" do
    should "change 'frames' with correct delay" do
      capture_stdout do |out|
        dots = Thread.new do
          SpinningCursor::Cursor.new("").spin :dots, delay
        end
        # slight delay to get things started
        sleep (delay/4.0)
        assert_equal "#{ESC_R_AND_CLR}.", out.string
        sleep delay
        assert_equal "#{ESC_R_AND_CLR}.#{ESC_R_AND_CLR}..", out.string
        # don't need to go through the whole thing, otherwise test will take
        # too long
        dots.kill
      end
    end
  end

  context "spinner" do
    should "cycle through correctly" do
      delay = 0.2
      capture_stdout do |out|
        spinner = Thread.new do
          SpinningCursor::Cursor.new("").spin :spinner, delay
        end
        # slight delay to get things started
        sleep (delay/3.0)
        buffer =  (ESC_R_AND_CLR + "|")
        assert_equal buffer, out.string
        buffer += (ESC_R_AND_CLR + "/")
        sleep delay
        assert_equal buffer, out.string
        buffer += (ESC_R_AND_CLR + "-")
        sleep delay
        assert_equal buffer, out.string
        buffer += (ESC_R_AND_CLR + "\\")
        sleep delay
        assert_equal buffer, out.string
        sleep delay
        buffer += (ESC_R_AND_CLR + "|")
        assert_equal buffer, out.string
        spinner.kill
      end
    end

    should "changes 'frames' with correct delay" do
      delay = 0.2
      capture_stdout do |out|
        spinner = Thread.new do
          SpinningCursor::Cursor.new("").spin :spinner, delay
        end
        sleep (delay/4.0)
        buffer = (ESC_R_AND_CLR + "|")
        assert_equal buffer, out.string
        buffer += (ESC_R_AND_CLR + "/")
        sleep delay
        # next frame after 'delay' second
        assert_equal buffer, out.string
        # don't need to go through the whole thing, otherwise test will take
        # too long
        spinner.kill
      end
    end
  end
end
