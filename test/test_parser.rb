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

  context "SpinningCursor#start" do
    context "with a block with 1 parameter (arity 1)" do
      setup do
        $outer_context = self
        capture_stdout do |out|
          SpinningCursor.start do |param|
            $inner_context = self
            $yielded_param = param
          end
        end
      end

      should "yield the Parser as parameter" do
        assert_equal Parser, $yielded_param.class
      end

      should "outer context be available (outer self = inner self)" do
        assert_equal $inner_context.object_id, $outer_context.object_id
      end
    end

    context "with a block without parameters (arity 0)" do
      setup do
        $outer_context = self
        capture_stdout do |out|
          SpinningCursor.start do
            $inner_context = self
          end
        end
      end

      should "instance_eval the block on Parser context" do
        assert_equal Parser, $inner_context.class
      end

      should "outer context NOT be available (outer self != inner self)" do
        assert_not_equal $outer_context.object_id, $inner_context.object_id
      end

    end
  end

  context "SpinningCursor::Parser method" do
    context "'type'" do
      should "raise ArgumentError if argument IS NOT a SpinningCursor::Cursor instance_method" do
        assert_raise(ArgumentError) { SpinningCursor::Parser.new.type :fake_method }
      end
      should "NOT raise anything if argument IS a SpinningCursor::Cursor instance_method" do
        assert_nothing_raised { SpinningCursor::Parser.new.type :dots }
      end
    end
    context "'delay'" do
      should "raise ArgumentError if argument IS NOT a Numeric" do
        assert_raise(ArgumentError) { SpinningCursor::Parser.new.delay "Not a number" }
      end
      should "NOT raise anything if argument IS a Numeric" do
        assert_nothing_raised { SpinningCursor::Parser.new.delay 10 }
      end
    end
    context "'output'" do
      should "raise ArgumentError if argument IS NOT :inline or :at_stop" do
        assert_raise(ArgumentError) { SpinningCursor::Parser.new.output :not_inline_nor_at_stop }
      end
      should "NOT raise anything if argument IS :inline or :at_stop" do
        assert_nothing_raised { SpinningCursor::Parser.new.output :inline }
        assert_nothing_raised { SpinningCursor::Parser.new.output :at_stop }
      end
    end
    context "'banner' and 'message'" do
      class LackingToSClass
        undef :to_s
      end

      should "raise ArgumentError if argument IS NOT a String nor respond_to :to_s (:banner)" do
        assert_raise(ArgumentError) { SpinningCursor::Parser.new.banner LackingToSClass.new }
      end
      should "raise ArgumentError if argument IS NOT a String nor respond_to :to_s (:message)" do
        assert_raise(ArgumentError) { SpinningCursor::Parser.new.message LackingToSClass.new }
      end
      should "NOT raise anything if argument IS a String or respond_to :to_s (:banner)" do
        assert_nothing_raised { SpinningCursor::Parser.new.banner "A String" }
      end
      should "NOT raise anything if argument IS a String or respond_to :to_s (:message)" do
        assert_nothing_raised { SpinningCursor::Parser.new.message "A String" }
      end
    end
  end
end
