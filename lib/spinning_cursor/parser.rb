module SpinningCursor
  class Parser
    attr_reader :originator

    #
    # Parses proc
    #
    def initialize(proc)
      @banner  = "Loading"
      @type    = :spinner
      @message = "Done"
      @delay   = nil

      if proc
        # Store the originating class for use in method_missing
        @originator = eval "self", proc.binding
        instance_eval &proc
      end

    end

    #
    # Getter and setter for the action block
    #
    def action(&block)
      @action = block if block

      @action
    end

    #
    # Getters and setters for +banner+, +type+ and +message+
    # attributes.
    # Note:: for getting use method without arguments
    #            e.g. <tt>banner</tt>
    #        for setting use method with arguments
    #            e.g. <tt>banner "my banner"</tt>.
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
      @originator.send method, *args, &block
    end
  end
end
