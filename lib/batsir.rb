require 'blockenspiel'
require 'celluloid'
require 'json'
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
require 'batsir/transformers/transformer'
require 'batsir/transformers/field_transformer'
require 'batsir/transformers/json_input_transformer'
require 'batsir/transformers/json_output_transformer'
require 'batsir/logo'

module Batsir
  def self.config
    @config ||= Batsir::Config.new(config_defaults)
  end

  def self.config_defaults
    {
      :redis_url => "redis://localhost:6379/0"
    }
  end

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

    initialize_sidekiq

    generated_code = @chain.compile

    eval(generated_code)

    @chain.start
    sidekiq_cli.run
  end

  def self.initialize_sidekiq
    Sidekiq.configure_server do |config|
      config.redis = {:url => Batsir.config.redis_url}
    end
    Sidekiq.configure_client do |config|
      config.redis = {:url => Batsir.config.redis_url}
    end
  end

  def self.create_and_start(&block)
    create(&block)
    start
  end
end
