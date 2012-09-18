require 'batsir/amqp'

module Batsir
  module Acceptors
    class AMQPAcceptor < Acceptor
      include Batsir::AMQP
      include Batsir::Log

      def start
        Bunny.run( bunny_options ) do |bunny|
          q   = bunny.queue( queue )
          exc = bunny.exchange( exchange )
          q.bind( exc, :key => queue)
          q.subscribe(:cancellator => cancellator) do |msg|
            start_filter_chain(msg[:payload])
          end
        end
      end

      def process_message_error(message, error)
        log.error error.message
        nil
      end
    end
  end
end
