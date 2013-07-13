class StopWatch

  #
  # Instantiate class and call {#measure}
  #
  def self.measure(&block)
    sw = self.new
    sw.measure &block
  end

  #
  # Measures the time taken to process the passed block and returns the
  # measurment (see {timing})
  #
  def measure(&block)
    start
    yield
    stop
    timing
  end

  #
  # Starts timer
  #
  def start
    @start_time = Time.now
    @stop_time = nil
    self
  end

  #
  # Stops timer
  #
  def stop
    if @start_time
      @stop_time = Time.now
    end
    self
  end

  #
  # Resets timer
  #
  def reset
    @start_time = @stop_time = nil
  end

  #
  # Returns the elapsed time
  # @note If the timer has not yet stopped, the time elapsed from the start of
  #   the timer till `Time.now` is returned
  #
  def elapsed_time
    time_now = Time.now
    (@stop_time || time_now ) - (@start_time || time_now)
  end

  alias old_inspect inspect

  def inspect
    puts "#{old_inspect} #{{:elapsed_time => elapsed_time}}"
  end

  #
  # Returns the measurement in a hash containing
  # * the start time
  # * the stop time
  # * the total elapsed time
  #
  def timing
    { :start_time   => @start_time,
      :stop_time    => @stop_time,
      :elapsed_time => elapsed_time }
  end

end


