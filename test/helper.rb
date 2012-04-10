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
 
module Kernel
  def capture_stdout
    out = StringIO.new
    $stdout = out
    yield out
  ensure
    $stdout = STDOUT
  end
end

class Test::Unit::TestCase
end
