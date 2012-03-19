module Batsir
  class Stage
    attr_accessor :name
    attr_accessor :queue
    attr_accessor :object_type
    attr_reader   :operation_queue
    attr_reader   :notification_queues


    def initialize(options = {})
      options.each do |attr, value|
        self.send("#{attr.to_s}=", value)
      end
      @notification_queues = {}
      @built = false
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

    def build
      @operation_queue = OperationQueue.new
      #OperationTypeMapping.all(:object_type => configuration.object_type).each do |operation_mapping|
      #  @operation_queue.add(operation_mapping.operation)
      #end
      @built = true
    end
  end
end
