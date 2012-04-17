require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rspec/core'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'batsir'
require 'batsir/support/mock_filters'

Celluloid.logger.level = Logger::ERROR
RSpec.configure do |config|
  config.after(:each) do
    Celluloid.shutdown
  end
end
