require 'batsir/amqp'

module Batsir
  module Notifiers
    class AMQPNotifier < Notifier
      include Batsir::AMQP

      attr_reader :error_strategy

      def initialize(options = {}, error_strategy = Batsir::Strategies::RetryStrategy)
        super(options)
        @error_strategy = error_strategy.new(self)
      end

      def execute(message)
        begin
          bunny_pool.with do |bunny|
            x = bunny.exchange(exchange)
            x.publish(message, :routing_key => queue)
          end
        rescue Bunny::ProtocolError => e
          handle_error(message, e)
        rescue Bunny::ForcedConnectionCloseError => e
          handle_error(message, e)
        end
      end

      def handle_error(message, error)
        @error_strategy.execute(message, error)
      end
    end
  end
end
