# encoding: utf-8

require 'rubygems'
require 'bundler'
begin
  Bundler.setup
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), 'lib'))

require 'rake'
require 'jeweler'
require 'batsir/version'

version = Batsir::VERSION

Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://docs.rubygems.org/read/chapter/20 for more options
  gem.name = "batsir"
  gem.version = version
  gem.homepage = "http://github.com/jwkoelewijn/batsir"
  gem.license = "MIT"
  gem.summary = %Q{Batsir is an execution platform for stage based operation queue execution}
  gem.description = %Q{Batsir uses so called stages to define operation queues. These operation queues
    consist of several operations that will be executed one after the other. Each stage
    is defined by its name and the queue on which it will listen. Once a message is received
    on the queue, it is dispatched to a worker in a seperate thread that will pass the message
    to each operation in the operation queue.
    Operation queues can have 4 different operations, 1 common operation type, and 3 special
    purpose operations: retrieval operations (which are always executed before all other operations),
    persistence operations (which are always executed after the common operations, but before the
    notification operations) and notification operations (which will always be executed last)
    This makes it possible to create chains of stages to perform tasks that depend on each
    other, but otherwise have a low coupling}
  gem.email = "jwkoelewijn@gmail.com"
  gem.authors = ["J.W. Koelewijn", "Bram de Vries"]
  gem.extra_rdoc_files << "CHANGES.md"
  # dependencies defined in Gemfile
end
Jeweler::RubygemsDotOrgTasks.new

require 'rspec/core/rake_task'

desc "Run specs"
RSpec::Core::RakeTask.new do |t|
  t.pattern = 'spec/**/*_spec.rb'
end

task :default => :spec

require 'rdoc/task'
Rake::RDocTask.new do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "batsir #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('CHANGES*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
