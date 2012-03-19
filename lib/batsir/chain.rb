module Batsir
  class Chain

    attr_accessor :retrieval_operation
    attr_accessor :persistence_operation

    def initialize
      @stages = []
    end

    def stages
      @stages
    end

    def add_stage(stage)
      @stages << stage
    end
  end
end
