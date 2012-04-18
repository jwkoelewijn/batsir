require 'blockenspiel'
require 'celluloid'
#require 'hot_bunnies'
require 'bunny'
require 'sidekiq'
require 'sidekiq/cli'
require 'batsir/registry'
require 'batsir/chain'
require 'batsir/filter'
require 'batsir/filter_queue'
require 'batsir/stage'
require 'batsir/stage_worker'
require 'batsir/dsl/dsl_mappings'
require 'batsir/acceptors/acceptor'
require 'batsir/acceptors/amqp_acceptor'
require 'batsir/notifiers/notifier'
require 'batsir/notifiers/amqp_notifier'
require 'batsir/logo'

module Batsir
  def self.create(&block)
    puts logo
    new_block = ::Proc.new do
      aggregator_chain &block
    end
    @chain = ::Blockenspiel.invoke(new_block, Batsir::DSL::ChainMapping.new)
  end

  def self.start
    return unless @chain
    
    sidekiq_cli = Sidekiq::CLI.instance
    Sidekiq.options[:queues] << 'default'
    generated_code = @chain.compile

    eval(generated_code)

    @chain.start
    sidekiq_cli.run
  end

  def self.create_and_start(&block)
    create(&block)
    start
  end
end
