require 'batsir/amqp'

module Batsir
  module Acceptors
    class AMQPAcceptor < Acceptor
      include Batsir::AMQP
      include Batsir::Log

      attr_reader :consumer
      attr_writer :consumer_source

      def initialize(options={})
        super
        @bunny = Bunny.new(bunny_options).start
        @channel = @bunny.create_channel
        @q = @channel.queue( queue, :durable => durable )

        @consumer = consumer_source.call(self, @channel, @q)
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

    private

      def consumer_source
        @consumer_source ||= Batsir::AMQPConsumer.public_method(:new)
      end

    end
  end
end
