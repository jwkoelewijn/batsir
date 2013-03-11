module Bunny
  def self.instance
    @instance
  end

  def self.run(options = {})
    @instance = BunnyInstance.new(options)
    yield @instance
  end

  def self.new(options = {})
    @instance = BunnyInstance.new(options)
    @instance
  end

  class Consumer
    def initialize(channel, queue, consumer_tag = 'test', no_ack = true, exclusive = false, arguments = {})
      @channel = channel
      @queue = queue
    end
  end

  class BunnyInstance
    attr_accessor :queues
    attr_accessor :options
    attr_accessor :channel
    attr_accessor :exchange

    def initialize(options = {})
      @options = options
      @queues = {}
    end

    def start
      @channel = create_channel
      self
    end

    def exchange(exchange = nil)
      @exchange = BunnyExchange.new(self, exchange) if exchange
      @exchange
    end

    def queue(queue)
      @queues[queue] = BunnyQueue.new
    end

    def create_channel
      self
    end

    def connection
      self
    end

    def host
      @options[:host]
    end

    def port
      @options[:port]
    end

    def user
      @options[:user]
    end

    def pass
      @options[:pass]
    end

    def vhost
      @options[:vhost]
    end

    def number
      1
    end
  end

  class BunnyExchange
    attr_accessor :name
    attr_accessor :key
    attr_accessor :message
    attr_accessor :channel

    def initialize(channel, name)
      @channel = channel
      @name = name
    end

    def publish(message, options = {})
      @key = options[:routing_key] || options[:key]
      @message = message
    end
  end

  class BunnyQueue
    attr_accessor :arguments
    attr_accessor :block
    attr_accessor :bound_exchange
    attr_accessor :bound_key
    attr_accessor :consumer

    def initialize
      @bindings = []
    end

    def bind(exchange, options)
      @bound_exchange = exchange

      @bound_key = options[:routing_key] || options[:key]
      @bindings << {:exchange => @bound_exchange.name, :routing_key => @bound_key}
    end

    def subscribe(*args, &block)
      @arguments = *args
      @block = block
    end

    def subscribe_with(consumer, opts = {:block => false})
      @block ||= opts[:block]
      @consumer = consumer
      @consumer
    end

    def name
      @bound_key
    end

    def channel
      @bound_exchange.channel
    end
  end
end
