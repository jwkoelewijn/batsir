module Batsir::MockBehavior
  attr_accessor :execute_count
  def initialize(options = {})
    super
    @execute_count = 0
  end

  def execute(*args)
    @execute_count += 1
  end
end

class Batsir::MockOperation < Batsir::Operation
  include Batsir::MockBehavior
end

class PersistenceOperation < Batsir::MockOperation
end

class SumOperation < Batsir::MockOperation
end

class AverageOperation < Batsir::MockOperation
end

class Batsir::RetrievalOperation
  include Batsir::MockBehavior
end
