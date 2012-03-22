module Batsir
  class OperationQueue
    include Enumerable

    attr_accessor :persist_operation
    attr_accessor :retrieval_operation
    attr_accessor :operations
    attr_accessor :notification_operations
    attr_accessor :instantiated

    def initialize
      @operations = []
      @notification_operations = []
      @instantiated = false
    end

    def add(operation)
      @operations.unshift(operation)
    end

    def retrieval_operation=(operation)
      if (operation.is_a?(Class) && operation.ancestors.include?(RetrievalOperation)) || operation.is_a?(RetrievalOperation)
        @retrieval_operation = operation
      else
        @retrieval_operation = nil
      end
    end

    def add_notification_operation(operation)
      @notification_operations << operation
    end

    def each
      if op = retrieval_operation
        yield op
      end
      @operations.each {|op| yield op}
      if op = persist_operation
        yield op
      end
      @notification_operations.each {|op| yield op}
    end

    def empty?
      !(persist_operation || retrieval_operation || @notification_operations.any? || @operations.any?)
    end

    def instantiated?
      @instantiated
    end

    def instantiate_for(stage)
      new_operation_queue = OperationQueue.new

      if retrieval_op = stage.retrieval_operation
        new_operation_queue.retrieval_operation = ensure_instance(retrieval_op)
        if retrieval_operation_instance = new_operation_queue.retrieval_operation
          retrieval_operation_instance.object_type = stage.object_type
        end
      end

      if persist_op = stage.persistence_operation
        new_operation_queue.persist_operation = ensure_instance(persist_op)
      end

      self.operations.each do |operation|
        new_operation_queue.add(ensure_instance(operation))
      end

      instantiate_notification_operations(stage, new_operation_queue)

      new_operation_queue.instantiated = true

      new_operation_queue
    end

    private
    def instantiate_notification_operations(stage, operation_queue)
      notification_op_klass = stage.notification_operation
      return unless notification_op_klass
      stage.notification_queues.each do | queue, parent_attribute |
        notification_op = ensure_instance(notification_op_klass)
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
