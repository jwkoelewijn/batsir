require 'batsir/amqp'

module Batsir
  module Acceptors
    class AMQPAcceptor < Acceptor
      include Batsir::AMQP
      include Batsir::Log

      attr_reader :consumer

      def start
        bunny_pool.with do |bunny|
          q = bunny.queue( queue )
          x = bunny.exchange( exchange )
          bind_queue_to_exchange(q,x)

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

      def bind_queue_to_exchange(q, x)
        max_retries = 3
        result = nil
        error = nil
        n = 0

        while !result && n < max_retries
          begin
            result = q.bind( x, :routing_key => queue)
          rescue ClientTimeout => error
            log.warn "Caught ClientTimeout while trying to bind queue to exchange, retrying (##{n+1})"
          ensure
            n += 1
          end
        end

        if !result && n >= max_retries
          raise error
        end

        result
      end

      def process_message_error(message, error)
        log.error error.message
        nil
      end
    end
  end
end
