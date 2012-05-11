module Bunny
  def self.instance
    @instance
  end

  def self.run(options = {})
    @instance = BunnyInstance.new(options)
    yield @instance
  end

  class BunnyInstance
    attr_accessor :queues
    attr_accessor :options
    attr_accessor :exchange

    def initialize(options = {})
      @options = options
      @queues = {}
    end

    def exchange(exchange = nil)
      @exchange = BunnyExchange.new(exchange) if exchange
      @exchange
    end

    def queue(queue)
      @queues[queue] = BunnyQueue.new
    end
  end

  class BunnyExchange
    attr_accessor :name
    attr_accessor :key
    attr_accessor :message

    def initialize(name)
      @name = name
    end

    def publish(message, options = {})
      @key = options[:key]
      @message = message
    end
  end

  class BunnyQueue
    attr_accessor :arguments
    attr_accessor :block
    attr_accessor :bound_exchange
    attr_accessor :bound_key

    def bind(exchange, options)
      @bound_exchange = exchange
      @bound_key = options[:key]
    end

    def subscribe(*args, &block)
      @arguments = *args
      @block = block
    end
  end
end
