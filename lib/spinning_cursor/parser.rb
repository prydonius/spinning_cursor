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
    %w[banner type message delay output].each do |method|
      define_method(method) do |*args|
        var = "@#{method}"
        return instance_variable_get(var) unless args.first
        instance_variable_set(var, args.first)
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
