module Batsir
  class FilterQueue
    include Enumerable

    attr_accessor :operations
    attr_accessor :notifiers

    def initialize
      @operations = []
      @notifiers = []
      @notification_operations = []
    end

    def add(operation)
      @operations.unshift(operation)
    end

    def add_notifier(notifier)
      @notifiers << notifier
    end

    def each
      @operations.each {|op| yield op}
      @notifiers.each {|n| yield n}
    end

    def empty?
      !(@notifiers.any? || @operations.any?)
    end
  end
end
