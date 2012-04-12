module Batsir
  class Stage
    include Celluloid

    attr_accessor :name
    attr_accessor :queue
    attr_accessor :object_type
    attr_accessor :chain
    attr_accessor :retrieval_operation
    attr_accessor :persistence_operation
    attr_accessor :notification_operation
    attr_reader   :operation_queue
    attr_reader   :notification_queues

    def initialize(options = {})
      options.each do |attr, value|
        self.send("#{attr.to_s}=", value)
      end
      @notification_queues = {}
      @built = false
    end

    def retrieval_operation
      @retrieval_operation || (chain ? chain.retrieval_operation : nil)
    end

    def persistence_operation
      @persistence_operation || (chain ? chain.persistence_operation : nil)
    end

    def notification_operation
      @notification_operation || (chain ? chain.notification_operation : nil)
    end

    def built?
      @built
    end

    def add_notification(notification_queue, parent_attribute)
      @notification_queues[notification_queue] = parent_attribute
    end

    def add_operation(operation)
      @operation_queue ||= OperationQueue.new
      @operation_queue.add(operation)
    end

    def compile
      @operation_queue.generate_code_for(self)
    end

    def start
      connection = HotBunnies.connect(:host => 'localhost')
      channel = connection.create_channel
      channel.prefetch = 10

      queue = channel.queue(self.queue)
      queue.purge

      subscription = queue.subscribe(:ack => true)
      subscription.each(:blocking => true) do |headers, msg|
        klazz = Registry.get(name)
        klazz.perform_async(msg)
        headers.ack
      end
      true
    end
  end
end
