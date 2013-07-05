require 'helper'

class TestSpinningCursorCursor < Test::Unit::TestCase
  context "dots" do
    parsed = Parser.new { type :dots; delay 0.2; banner ""}
    delay = parsed.delay
    should "change 'frames' with correct delay" do
      capture_stdout do |out|
        dots = Thread.new do
          SpinningCursor::Cursor.new(parsed).spin
        end
        # slight delay to get things started
        sleep (delay/4.0)
        buffer = "#{ESC_R_AND_CLR}" << "."
        assert_equal buffer, out.string

        sleep delay
        buffer << "#{ESC_R_AND_CLR}" << ".."
        assert_equal buffer, out.string

        sleep delay
        buffer << "#{ESC_R_AND_CLR}" << "..."
        assert_equal buffer, out.string

        sleep delay
        buffer << "#{ESC_R_AND_CLR}"
        assert_equal buffer, out.string
        # don't need to go through the whole thing, otherwise test will take
        # too long
        dots.kill
      end
    end
  end

  context "spinner" do
    should "cycle through correctly" do
      parsed = Parser.new { type :spinner; delay 0.2; banner ""}
      delay = parsed.delay
      capture_stdout do |out|
        spinner = Thread.new do
          SpinningCursor::Cursor.new(parsed).spin
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
      parsed = Parser.new { type :spinner; delay 0.2; banner ""}
      delay = parsed.delay
      capture_stdout do |out|
        spinner = Thread.new do
          SpinningCursor::Cursor.new(parsed).spin
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
