require 'helper'

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
    setup do
      parsed = Parser.new { type :dots; delay 0.2; banner ""}
      @delay = parsed.delay
      $cycle_steps = []
      $cycle_times = []
      capture_stdout do |out|
        spinner = Thread.new do
          test_cursor = SpinningCursor::Cursor.new(parsed)
          class << test_cursor
            def reset_line(str)
              $cycle_steps.push str
              $cycle_times.push Time.now
              Thread.current.kill if $cycle_times.size == 5
            end
          end
          test_cursor.spin
        end
        spinner.join
      end
    end

    should "change 'frames' with correct delay" do
      $cycle_times.each_cons(2) do |t1, t2|
        interval = t2-t1
        assert (interval > @delay and interval < (1.5 * @delay))
      end
    end

    should "cycle through correctly" do
      assert_equal [".", "..", "...", "", "."], $cycle_steps
    end
  end

  context "spinner" do
    setup do
      parsed = Parser.new { type :spinner; delay 0.2; banner ""}
      @delay = parsed.delay
      $cycle_steps = []
      $cycle_times = []
      capture_stdout do |out|
        spinner = Thread.new do
          test_cursor = SpinningCursor::Cursor.new(parsed)
          class << test_cursor
            def reset_line(str)
              $cycle_steps.push str
              $cycle_times.push Time.now
              Thread.current.kill if $cycle_times.size == 5
            end
          end
          test_cursor.spin
        end
        spinner.join
      end
    end

    should "change 'frames' with correct delay" do
      $cycle_times.each_cons(2) do |t1, t2|
        interval = t2-t1
        assert (interval > @delay and interval < (1.5 * @delay))
      end
    end

    should "cycle through correctly" do
      assert_equal ["|", "/", "-", "\\", "|"], $cycle_steps
    end
  end
end
