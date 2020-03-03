# encoding: utf-8
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), 'lib'))

# Bundler
require 'bundler'
require "bundler/gem_tasks"
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end

# Rake
require 'rake'
require 'rspec/core/rake_task'

module TempFixForRakeLastComment
  def last_comment
    last_description
  end 
end
Rake::Application.send :include, TempFixForRakeLastComment

desc "Run specs"
RSpec::Core::RakeTask.new do |t|
  t.pattern = 'spec/**/*_spec.rb'
end

task :default => :spec

require 'rdoc/task'
require 'batsir/version'
version = Batsir::VERSION
Rake::RDocTask.new do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "batsir #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('CHANGES*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
