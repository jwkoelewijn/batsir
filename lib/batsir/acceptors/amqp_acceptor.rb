require 'batsir/amqp'

module Batsir
  module Acceptors
    class AMQPAcceptor < Acceptor
      include Batsir::AMQP
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
    end
  end
end
