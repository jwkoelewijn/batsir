require 'batsir/amqp'

module Batsir
  module Notifiers
    class AMQPNotifier < Notifier
      include Batsir::AMQP

      attr_reader :error_strategy

      def initialize(options = {}, error_strategy = Batsir::Strategies::RetryStrategy)
        super(options)
        @error_strategy = error_strategy.new(self)
        @bunny = Bunny.new(bunny_options).start
        @channel = @bunny.create_channel
        @queue = @channel.queue(queue, durable: durable)
      end

      def execute(message)
        @queue.publish(message, :routing_key => queue)
      end

      def handle_error(message, error)
        @error_strategy.execute(message, error)
      end
    end
  end
end
