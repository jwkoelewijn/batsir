module Batsir
  module AMQP
    attr_accessor :queue
    attr_accessor :host
    attr_accessor :port
    attr_accessor :username
    attr_accessor :password
    attr_accessor :vhost
    attr_accessor :exchange

    def bunny_options
      {
        :host  => host,
        :port  => port,
        :user  => username,
        :pass  => password,
        :vhost => vhost
      }
    end

    def host
      @host || Batsir::Config.fetch(:amqp_host, 'localhost')
    end

    def port
      @port || Batsir::Config.fetch(:amqp_port, 5672)
    end

    def username
      @username || Batsir::Config.fetch(:amqp_user, 'guest')
    end

    def password
      @password || Batsir::Config.fetch(:amqp_pass, 'guest')
    end

    def vhost
      @vhost || Batsir::Config.fetch(:amqp_vhost, '/')
    end

    def exchange
      @exchange || Batsir::Config.fetch(:amqp_exchange, 'amq.direct')
    end
  end
end
