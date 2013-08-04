module SpinningCursor
  class Parser
    attr_accessor :outer_scope_object

    #
    # Parses proc
    #
    def initialize(&block)
      @banner  = "Loading"
      @type    = :spinner
      @message = "Done"
      @delay   = nil
      @action  = nil
      @output  = :inline

      if block_given?
        @outer_scope_object = eval("self", block.binding)
        if block.arity == 1
          yield self
        else
          instance_eval &block
        end
      end
    end

    #
    # Getter and setter for the action block
    #
    def action(&block)
      @action = block if block

      @action
    end

    # @method banner(banner)
    # @method type(type)
    # @method message(message)
    # @method delay(delay)
    # @method output(output)
    # Getters and setters for `banner`, `type`, `message`, `delay` and `output`
    # attributes
    # @note For getting, use method without arguments
    #   e.g. `banner`<br />
    #   For setting, use method with arguments
    #   e.g. `banner "my banner"`
    #

    methods_and_validations = {
      :type    => Proc.new { |arg|
        inst_methods = SpinningCursor::Cursor.public_instance_methods |
                       SpinningCursor::Cursor.private_instance_methods |
                       SpinningCursor::Cursor.protected_instance_methods
        inst_methods.include?(arg) ? arg : false },
      :delay   => Proc.new { |arg| arg.respond_to?(:to_f) ? arg.to_f : false},
      :output  => Proc.new { |arg| [:inline, :at_stop].include?(arg) ? arg : false},
      :banner  => Proc.new { |arg| arg.respond_to?(:to_s) ? arg.to_s : false},
      :message => Proc.new { |arg| arg.respond_to?(:to_s) ? arg.to_s : false},
    }

    methods_and_validations.each do |method, validation|
      define_method(method) do |*args|
        var = "@#{method}"
        arg = args.first
        if arg
          valid_arg = validation.call(arg)
          raise ArgumentError unless valid_arg
          instance_variable_set(var, valid_arg)
        else
          instance_variable_get(var)
        end
      end
    end

    private

    #
    # Pass any other methods to the calling class
    #
    def method_missing(method, *args, &block)
      @outer_scope_object.send method, *args, &block
    end
  end
end
