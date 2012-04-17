module Batsir
  class Stage
    include Celluloid

    attr_accessor :name
    attr_accessor :chain
    attr_reader   :filters
    attr_reader   :notifiers
    attr_reader   :acceptors

    def initialize(options = {})
      options.each do |attr, value|
        self.send("#{attr.to_s}=", value)
      end
      @acceptors = {}
      @filters   = {}
      @notifiers = {}
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

    def add_filter(filter, options = {})
      @filters[filter] = options
    end

    def compile
      Batsir::StageWorker.compile_from(self)
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
