module Batsir
  module AMQP
    attr_accessor :queue
    attr_accessor :host
    attr_accessor :port
    attr_accessor :username
    attr_accessor :password
    attr_accessor :vhost
    attr_accessor :exchange
    attr_accessor :heartbeat

    def bunny_options
      {
        :host  => host,
        :port  => port,
        :user  => username,
        :pass  => password,
        :vhost => vhost,
        :heartbeat => heartbeat
      }
    end

    def host
      @host ||= Batsir::Config.fetch(:amqp_host, 'localhost')
    end

    def port
      @port ||= Batsir::Config.fetch(:amqp_port, 5672)
    end

    def username
      @username ||= Batsir::Config.fetch(:amqp_user, 'guest')
    end

    def password
      @password ||= Batsir::Config.fetch(:amqp_pass, 'guest')
    end

    def vhost
      @vhost ||= Batsir::Config.fetch(:amqp_vhost, '/')
    end

    def exchange
      @exchange ||= Batsir::Config.fetch(:amqp_exchange, 'amq.direct')
    end

    def heartbeat
      @heartbeat ||= Batsir::Config.fetch(:amqp_heartbeat, 0) # default to AMQP 0.8 heartbeat setting
    end

    def bunny_pool_size
      @bunny_pool_size ||= Batsir::Config.ampq_pool_size
    end

    def bunny_pool_key
      "bunny_pool_for_#{host}_#{port}_#{vhost}"
    end

    def bunny_pool
      @bunny_pool = Batsir::Registry.get(bunny_pool_key)
      if !@bunny_pool
        pool = ConnectionPool.new(:size => bunny_pool_size) { Bunny.new(bunny_options).start }
        @bunny_pool = Batsir::Registry.register(bunny_pool_key, pool)
      end
      @bunny_pool
    end
  end
end
