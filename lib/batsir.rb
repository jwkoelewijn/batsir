require 'blockenspiel'
require 'celluloid'
require 'json'
require 'log4r'
require 'bunny'
require 'sidekiq'
require 'sidekiq/cli'
require 'batsir/amqp_consumer'
require 'batsir/config'
require 'batsir/chain'
require 'batsir/errors'
require 'batsir/filter'
require 'batsir/filter_queue'
require 'batsir/log'
require 'batsir/logger'
require 'batsir/logo'
require 'batsir/registry'
require 'batsir/stage'
require 'batsir/stage_worker'
require 'batsir/compiler/stage_worker_compiler'
require 'batsir/dsl/dsl_mappings'
require 'batsir/dsl/conditional_notifier_declaration'
require 'batsir/acceptors/acceptor'
require 'batsir/acceptors/amqp_acceptor'
require 'batsir/notifiers/notifier'
require 'batsir/notifiers/amqp_notifier'
require 'batsir/notifiers/conditional_notifier'
require 'batsir/transformers/transformer'
require 'batsir/transformers/field_transformer'
require 'batsir/transformers/json_input_transformer'
require 'batsir/transformers/json_output_transformer'
require 'batsir/strategies/strategy'
require 'batsir/strategies/retry_strategy'
require 'batsir/version'

module Batsir

  def self.config
    Batsir::Config
  end

  def self.create(&block)
    puts logo
    new_block = ::Proc.new do
      aggregator_chain(&block)
    end
    @chain = ::Blockenspiel.invoke(new_block, Batsir::DSL::ChainMapping.new)
  end

  def self.start
    return unless @chain

    sidekiq_cli = Sidekiq::CLI.instance
    Sidekiq.options[:queues] << Batsir::Config.sidekiq_queue

    initialize_sidekiq

    generated_code = @chain.compile

    eval(generated_code)

    @chain.start
    sidekiq_cli.run
  end

  def self.initialize_sidekiq
    Sidekiq.logger = Batsir::Logger.log
    Sidekiq.configure_server do |config|
      config.redis = {:url => Batsir.redis_url}
    end
    Sidekiq.configure_client do |config|
      config.redis = {:url => Batsir.redis_url}
    end
  end

  def self.create_and_start(&block)
    create(&block)
    start
  end

  def self.redis_url
    host = Batsir::Config.redis_host
    port = Batsir::Config.redis_port
    dbase = Batsir::Config.redis_database
    "redis://#{host}:#{port}/#{dbase}"
  end
end
