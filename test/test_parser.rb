require 'helper'

class TestSpinningCursorParser < Test::Unit::TestCase
  context "parser" do
    should "check calling class for any missing methods" do
      def banner_text
        "Banner"
      end
      parser = SpinningCursor::Parser.new Proc.new { banner banner_text }
      assert_equal banner_text, (parser.banner nil)
    end
  end

  context "banner, type, message, delay and action methods" do
    setup do
      @parser = SpinningCursor::Parser.new Proc.new { }
    end

    should "act as getters and setters" do
      @parser.banner "a new banner"
      assert_equal "a new banner", (@parser.banner nil)

      @parser.type :dots
      assert_equal :dots, (@parser.type nil)

      @parser.message "a message"
      assert_equal "a message", (@parser.message nil)

      @parser.delay 5
      assert_equal 5, (@parser.delay nil)

      proc = Proc.new { }
      @parser.action &proc
      assert_equal proc, @parser.action
    end
  end
end
