module Batsir
  module Notifiers
    class AMQPNotifier < Notifier
      attr_accessor :queue
      attr_accessor :host
      attr_accessor :port
      attr_accessor :username
      attr_accessor :password
      attr_accessor :vhost
      attr_accessor :exchange

      def execute(message)
        bunny_options = {
          :host  => host,
          :port  => port,
          :user  => username,
          :pass  => password,
          :vhost => vhost
        }

        Bunny.run( bunny_options )do |bunny|
          exc = bunny.exchange( exchange )
          exc.publish( message, :key => queue )
        end
      end

      def host
        @host || 'localhost'
      end

      def port
        @port || 5672
      end

      def username
        @username || 'guest'
      end

      def password
        @password || 'guest'
      end

      def vhost
        @vhost || ''
      end

      def exchange
        @exchange || 'amq.direct'
      end
    end
  end
end
