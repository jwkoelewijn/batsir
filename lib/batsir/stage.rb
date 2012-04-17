module Batsir
  class Stage
    include Celluloid

    attr_accessor :name
    attr_accessor :chain
    attr_reader   :filter_queue
    attr_reader   :notifiers
    attr_reader   :acceptors

    def initialize(options = {})
      options.each do |attr, value|
        self.send("#{attr.to_s}=", value)
      end
      @notification_queues = {}
      @notifiers = {}
      @acceptors = {}
      @built = false
    end

    def built?
      @built
    end

    def add_notifier(notifier, options = {})
      @notifiers[notifier] = options
    end

    def add_acceptor(acceptor, options = {})
      @acceptors[acceptor] = options
    end

    def add_filter(filter)
      @filter_queue ||= FilterQueue.new
      @filter_queue.add(filter)
    end

    def compile
      @filter_queue ||= FilterQueue.new
      @filter_queue.generate_code_for(self)
    end

    def start
      #connection = HotBunnies.connect(:host => 'localhost')
      #channel = connection.create_channel
      #channel.prefetch = 10

      #exchange = channel.exchange('', :type => :direct)
      #queue = channel.queue(self.queue.to_s)
      #queue.purge

      #subscription = queue.subscribe(:ack => true)
      #subscription.each(:blocking => true) do |headers, msg|
      #  klazz = Registry.get(name)
      #  klazz.perform_async(msg)
      #  headers.ack
      #end
      true
    end
  end
end
