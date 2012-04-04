module Batsir
  class Chain
    include Celluloid

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

    def compile
      generated = ""
      stages.each do |stage|
         generated << stage.compile
      end
      generated
    end

    def start
      stages.each do | stage |
        stage.start!
      end
    end
  end
end
