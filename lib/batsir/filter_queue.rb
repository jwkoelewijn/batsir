module Batsir
  class FilterQueue
    include Enumerable

    attr_accessor :filters
    attr_accessor :notifiers

    def initialize
      @filters = []
      @notifiers = []
    end

    def add(operation)
      @filters.unshift(operation)
    end

    def add_notifier(notifier)
      @notifiers << notifier
    end

    def each
      @filters.each {|op| yield op}
      @notifiers.each {|n| yield n}
    end

    def empty?
      !(@notifiers.any? || @filters.any?)
    end
  end
end
