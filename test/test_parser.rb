require 'helper'

class TestSpinningCursorParser < Test::Unit::TestCase
  context "A Parser instance" do
    should "always respond to outer_scope_object method" do
      assert_respond_to Parser.new, :outer_scope_object
    end

    context "initialized WITHOUT a block" do
      should "have outer_scope_object equal nil" do
        assert_equal nil, Parser.new.outer_scope_object
      end
    end

    context "initialized WITH a block" do
      should "have outer_scope_object point to 'caller'" do
        parsed = Parser.new {}
        assert_equal self, parsed.outer_scope_object
      end

      context "having an 'action' block within this block" do
        should "have this action block retrievable with Parser#action" do
          action_block = Proc.new { }
          parsed = Parser.new do
                     action &action_block
                   end
          assert_equal action_block, parsed.action
        end
      end

      context "and instance evaluating this block at Parser context" do
        should "NOT have access to instance variables of outer_scope_object from inside the block" do
          @outer_instance_variable = 1
          parsed = Parser.new { @outer_instance_variable = 2 }
          assert_not_equal 2, @outer_instance_variable
          assert_equal     2, parsed.instance_variable_get(:@outer_instance_variable)
        end

        should "have direct access to instance variables of the Parser instance itself" do
          parsed = Parser.new { @banner = "this is Parser instance"}
          assert_equal parsed.banner, "this is Parser instance"
        end

        should "have access to methods of outer_scope_object from inside the block (thanks method_missing)" do
          def outer_method
            "Outer Method"
          end
          parsed = Parser.new { banner outer_method }
          assert_equal outer_method, parsed.banner
        end
      end
    end
  end

  context "banner, type, message, delay and action methods" do
    setup do
      @parser = SpinningCursor::Parser.new
    end

    should "act as getters and setters" do
      @parser.banner "a new banner"
      assert_equal "a new banner", @parser.banner

      @parser.type :dots
      assert_equal :dots, @parser.type

      @parser.message "a message"
      assert_equal "a message", @parser.message

      @parser.delay 5
      assert_equal 5, @parser.delay

      proc = Proc.new { }
      @parser.action &proc
      assert_equal proc, @parser.action
    end
  end
end
