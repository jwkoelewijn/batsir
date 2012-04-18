module Batsir::MockBehavior
  attr_accessor :execute_count
  def initialize(options = {})
    super
    @execute_count = 0
  end

  def execute(message)
    @execute_count += 1
  end
end

class Batsir::MockFilter < Batsir::Filter
  include Batsir::MockBehavior
end

class PersistenceFilter < Batsir::MockFilter
end

class SumFilter < Batsir::MockFilter
end

class AverageFilter < Batsir::MockFilter
end

class Batsir::RetrievalFilter
  include Batsir::MockBehavior
end

class Batsir::MessagePrinter < Batsir::Filter
  def execute(message)
    puts "In #{self.class.to_s}#execute(#{message.inspect})"
    puts message
    message
  end
end

class Batsir::MessageCreator < Batsir::Filter
  def execute(message)
    puts "In #{self.class.to_s}#execute(#{message.inspect})"
    {:id => message}
  end
end
