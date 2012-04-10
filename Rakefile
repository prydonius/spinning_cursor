# encoding: utf-8

require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'

require 'jeweler'
Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://docs.rubygems.org/read/chapter/20 for more options
  gem.name = "spinning_cursor"
  gem.homepage = "http://github.com/Prydonius/spinning_cursor"
  gem.license = "MIT"
  gem.summary = "A DSL for adding animated loaders to your Ruby command line application."
  gem.description = "Spinning Cursor is a flexible DSL that allows you to easily produce a customizable waiting/loading message for your Ruby command line program. Beautifully keep your users informed with what your program is doing when a more complex solution, such as a progress bar, doesn't fit your needs."
  gem.email = "adnan@prydoni.us"
  gem.authors = ["Adnan Abdulhussein"]
  # dependencies defined in Gemfile
end
Jeweler::RubygemsDotOrgTasks.new

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

task :default => :test
