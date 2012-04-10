require 'helper'

class TestSpinningCursor < Test::Unit::TestCase
  context "when an action block is passed it" do
    should "start the cursor, run block content and kill the cursor" do
      # Hide any output
      capture_stdout do |out|
        SpinningCursor.start do
          action { sleep 1 }
        end
        # Give it some time to abort
        sleep 0.1
        assert_equal false, SpinningCursor.alive?
      end
    end

    should "evalute the block from the calling class" do
      @num = 1
      capture_stdout do |out|
        SpinningCursor.start do
          action { @num += 1 }
        end

        assert_equal 2, @num
      end
    end
  end

  context "when an action block isn't passed it" do
    should "start the cursor, and keep it going until stop is called" do
      capture_stdout do |out|
        SpinningCursor.start do
          banner "no action block"
        end
        sleep 2
        assert_equal true, SpinningCursor.alive?
        SpinningCursor.stop
        sleep 0.1
        assert_equal false, SpinningCursor.alive?
      end
    end
  end

  context "whilst running it" do
    should "allow you to change the end message" do
      capture_stdout do |out|
        SpinningCursor.start do
          action do
            SpinningCursor.set_message "Failed!"
          end
          message "Finished!"
        end

        assert_equal true, (out.string.end_with? "Failed!\n")
      end
    end
  end
end
