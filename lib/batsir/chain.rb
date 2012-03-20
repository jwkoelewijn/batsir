module Batsir
  class Chain

    attr_accessor :retrieval_operation
    attr_accessor :persistence_operation
    attr_accessor :notification_operation

    def initialize(options = {})
      options.each do |attr, value|
        self.send("#{attr.to_s}=", value)
      end
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
