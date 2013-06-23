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

      self
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
    # Note:: for getting, pass nil e.g. <tt>banner nil</tt>
    #
    %w[banner type message delay].each do |method|
      define_method(method) do |arg|
        var = "@#{method}"
        return instance_variable_get(var) if arg.nil?
        instance_variable_set(var, arg)
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
