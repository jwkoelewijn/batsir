require 'batsir/amqp'

module Batsir
  module Acceptors
    class AMQPAcceptor < Acceptor
      include Batsir::AMQP
      include Batsir::Log

      attr_reader :consumer

      def initialize(options={})
        super
        @bunny = Bunny.new(bunny_options).start
        @q = @bunny.queue( queue )
        @x = @bunny.exchange( exchange )
        @q.bind( @x, :routing_key => queue)

        @consumer = Batsir::AMQPConsumer.new(self, @bunny, @q)
        @consumer.on_delivery() do |delivery_info, metadata, payload|
          handle_delivery(payload)
        end
      end

      def start
        @q.subscribe_with(@consumer)
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
