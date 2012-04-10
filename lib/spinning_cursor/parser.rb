module SpinningCursor
  class Parser
    attr_reader :originator

    #
    # Parses proc
    #
    def initialize(proc)
      @banner = "Loading"
      @type = :spinner
      @message = "Done"

      if not proc.nil?
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
      @action = block unless block.nil?

      @action
    end

    #
    # Getters and setters for +banner+, +type+ and +message+
    # attributes.
    # Note:: for getting, pass nil e.g. <tt>banner nil</tt>
    #
    %w[banner type message].each do |method|
      define_method(method) do |string|
        var = "@#{method}"
        return instance_variable_get(var) if string.nil?
        instance_variable_set(var, string)
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