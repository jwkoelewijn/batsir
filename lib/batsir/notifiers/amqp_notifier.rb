require 'batsir/amqp'

module Batsir
  module Notifiers
    class AMQPNotifier < Notifier
      include Batsir::AMQP

      def execute(message)
        Bunny.run( bunny_options )do |bunny|
          exc = bunny.exchange( exchange )
          exc.publish( message, :key => queue )
        end
      end
    end
  end
end
