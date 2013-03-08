require 'batsir/amqp'

module Batsir
  module Acceptors
    class AMQPAcceptor < Acceptor
      include Batsir::AMQP
      include Batsir::Log

      attr_reader :bunny_pool
      attr_reader :consumer

      def initialize(options = {})
        super
        bunny_pool_id   = "bunny_pool"
        bunny_pool_size = Batsir::Config.connection_pool_size
        @bunny_pool = Batsir::Registry.get(bunny_pool_id)
        @bunny_pool ||= Batsir::Registry.register(bunny_pool_id, ConnectionPool.new(:size => bunny_pool_size) { Bunny.new(bunny_options).start })
      end

      def start
        @bunny_pool.with do |bunny|
          q = bunny.queue( queue )
          x = bunny.exchange( exchange )
          q.bind( x, :routing_key => queue)

          @consumer = Batsir::AMQPConsumer.new(self, bunny, q)
          @consumer.on_delivery() do |delivery_info, metadata, payload|
            handle_delivery(payload)
          end
          q.subscribe_with(@consumer)
        end
      end

      def handle_delivery(payload)
        start_filter_chain(payload)
      end

      def process_message_error(message, error)
        log.error error.message
        nil
      end
    end
  end
end
