class StopWatch

    def self.measure(&block)
      sw = self.new
      sw.measure &block
    end

    def measure(&block)
      start
      yield
      stop
      timing
    end

    def start
      @start_time = Time.now
      @stop_time = nil
      self
    end

    def stop
      if @start_time
        @stop_time = Time.now
      end
      self
    end

    def reset
      @start_time = @stop_time = nil
    end

    def elapsed_time
      time_now = Time.now
      (@stop_time || time_now ) - (@start_time || time_now)
    end

    alias old_inspect inspect

    def inspect
      puts "#{old_inspect} #{{:elapsed_time => elapsed_time}}"
    end

    def timing
      [ :start_time   => @start_time,
        :stop_time    => @stop_time,
        :elapsed_time => elapsed_time ]
    end

end


