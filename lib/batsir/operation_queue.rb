module Batsir
  class OperationQueue
    include Enumerable

    attr_accessor :persist_operation
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
  end
end
