module Batsir
  class Stage
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

    def build
      return unless (chain && queue && object_type)
      instantiate_operation_queue
      @built = true
    end

    def execute(*args)
      return false unless built?
      @operation_queue.each do |operation|
        operation.execute(*args)
      end
      true
    end

    private
    def instantiate_operation_queue
      @operation_queue ||= OperationQueue.new
      new_operation_queue = OperationQueue.new

      [:persist_operation, :retrieval_operation].each do |operation|
        if op = @operation_queue.send(operation)
          new_operations.send("#{operation}=", ensure_instance(op))
        end
      end

      @operation_queue.operations.each do |operation|
        new_operation_queue.add(ensure_instance(operation))
      end

      instantiate_notification_operations(new_operation_queue)

      @operation_queue = new_operation_queue
    end

    def instantiate_notification_operations(operation_queue)
      notification_op = notification_operation
      return unless notification_op
      notification_queues.each do | queue, parent_attribute |
        notification_op = ensure_instance(notification_op)
        notification_op.queue = queue
        notification_op.parent_attribute = parent_attribute
        operation_queue.add_notification_operation( notification_op )
      end
    end

    def ensure_instance(object)
      object.is_a?(Class) ? object.new : object
    end
  end
end
