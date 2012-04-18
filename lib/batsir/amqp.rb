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
