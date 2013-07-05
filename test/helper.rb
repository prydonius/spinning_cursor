require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'test/unit'
require 'shoulda'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'spinning_cursor'

# Allows capturing of stdout
# (http://thinkingdigitally.com/archive/capturing-output-from-puts-in-ruby/)

require 'stringio'

def kill_other_threads
  other_threads = Thread.list - [Thread.current]
  other_threads.each do |th|
    th.kill
    th.join
  end
end
 
module Kernel
  def capture_stdout
    SpinningCursor.capture_console
    out = StringIO.new
    $console = out
    yield out
  ensure
    kill_other_threads
    $console = STDOUT
    SpinningCursor.release_console
  end
end

include SpinningCursor

Thread.abort_on_exception=true

class Test::Unit::TestCase
end
