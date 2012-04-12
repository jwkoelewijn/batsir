module Batsir
  class OperationQueue
    include Enumerable

    attr_accessor :persistence_operation
    attr_accessor :retrieval_operation
    attr_accessor :operations
    attr_accessor :notification_operations

    def initialize
      @operations = []
      @notification_operations = []
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
      if op = persistence_operation
        yield op
      end
      @notification_operations.each {|op| yield op}
    end

    def empty?
      !(persistence_operation || retrieval_operation || @notification_operations.any? || @operations.any?)
    end

    def generate_code_for(stage)
      code = <<-EOF
          class #{stage.name.capitalize.gsub(' ','')}Worker
            def self.stage_name
              "#{stage.name}"
            end

            def initialize
              @operation_queue = self.class.operation_queue
            end

            def self.operation_queue
              @operation_queue
            end

            def self.initialize_operation_queue
              @operation_queue = OperationQueue.new
      EOF

      if retrieval_op = stage.retrieval_operation
        code << <<-EOF
              retrieval_operation = #{retrieval_op.to_s}.new
              @operation_queue.retrieval_operation = retrieval_operation
        EOF
      end

      if persist_op = stage.persistence_operation
        code << <<-EOF
              @operation_queue.persistence_operation = #{persist_op.to_s}.new
        EOF
      end

      self.operations.each do |operation|
        code << <<-EOF
              @operation_queue.add #{operation.to_s}.new
        EOF
      end
      if notification_op_klass = stage.notification_operation
        stage.notification_queues.each do | queue, parent_attribute |
          code << <<-EOF
              @operation_queue.add_notification_operation( 
                #{notification_op_klass.to_s}.new(
                    :queue => :#{queue}, 
                    :parent_attribute => :#{parent_attribute}
                )
              )
          EOF
        end
      end
      code << <<-EOF
            end

            include Sidekiq::Worker
            include Batsir::StageWorker
          end
      EOF
      code
    end
  end
end
