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
  gem.name = "batsir"
  gem.homepage = "http://github.com/jwkoelewijn/batsir"
  gem.license = "MIT"
  gem.summary = %Q{TODO: one-line summary of your gem}
  gem.description = %Q{TODO: longer description of your gem}
  gem.email = "jwkoelewijn@gmail.com"
  gem.authors = ["J.W. Koelewijn"]
  # dependencies defined in Gemfile
end
Jeweler::RubygemsDotOrgTasks.new

require 'rspec/core/rake_task'

desc "Run specs"
RSpec::Core::RakeTask.new do |t|
  t.pattern = 'spec/**/*_spec.rb'
end

RSpec::Core::RakeTask.new(:coverage) do |t|
  t.pattern = 'spec/**/*_spec.rb'
  t.rcov = true
  t.rcov_opts = ['--exclude', 'spec']
end

task :default => :spec

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "batsir #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

task :run_chain do
  begin
    Bundler.setup(:default, :development)
  rescue Bundler::BundlerError => e
    $stderr.puts e.message
    $stderr.puts "Run `bundle install` to install missing gems"
    exit e.status_code
  end
  $LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
  require 'batsir'
  require 'batsir/support/mock_operations'

  Batsir.create_and_start do
    retrieval_operation Batsir::RetrievalOperation
    persistence_operation PersistenceOperation
    notification_operation Batsir::NotificationOperation

    stage "stage 1" do
      queue :timecard_updated
      object_type Object
      operations do
        add_operation SumOperation
        add_operation AverageOperation
      end
      notifications do
        queue :receive_queue_2, :object_id
      end
    end

    stage "stage 2" do
      queue :receive_queue_2
      object_type String
      operations do
        add_operation SumOperation
      end
    end
  end
end
