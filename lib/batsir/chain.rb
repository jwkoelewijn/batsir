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

    def self.instance
      @@instance
    end

    def self.reset!
      @@instance = Batsir::Chain.send(:new)
    end

    @@instance = Batsir::Chain.new
    private_class_method :new
  end
end
