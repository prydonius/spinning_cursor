require 'helper'
require 'curses'

class TestSpinningCursorCursor < Test::Unit::TestCase
  context "SpinningCursor::ConsoleHelpers.reset_line" do
    # get the current shell width
    cols = SpinningCursor::ConsoleHelpers.console_columns
    regex = Regexp.new(Regexp.escape("#{ESC_R_AND_CLR}#{ESC_UP_A_LINE}"))
    should "not clear lines above if it fits within the width of the shell" do
      # general case
      capture_stdout do |out|
        SpinningCursor.start do
          banner (1..cols-20).map { ('a'..'z').to_a[rand(26)] }.join
          action { sleep 0.1 }
        end
        assert_no_match regex, out.string
      end
    end

    should "not clear lines above if it fits exactly on the line (edge case)" do
      capture_stdout do |out|
        SpinningCursor.start do
          # spinner type takes up two characters, so minus 2 to fit exactly
          banner (1..cols-2).map { ('a'..'z').to_a[rand(26)] }.join
          action { sleep 0.1 }
        end
        assert_no_match regex, out.string
      end
    end

    should "clear lines above if banner message overflows" do
      capture_stdout do |out|
        SpinningCursor.start do
          # spinner type takes up two characters, so minus 2 to fit exactly
          banner (1..400).map { ('a'..'z').to_a[rand(26)] }.join
          action { sleep 0.1 }
        end
        assert_match regex, out.string
      end
    end

    should "clear lines above if banner message overflows (edge case)" do
      capture_stdout do |out|
        SpinningCursor.start do
          # spinner type takes up two characters, so minus 2 to fit exactly
          banner (1..cols-1).map { ('a'..'z').to_a[rand(26)] }.join
          action { sleep 0.1 }
        end
        assert_match regex, out.string
      end
    end
  end

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
