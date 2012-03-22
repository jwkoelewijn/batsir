module Batsir
  class StageActor
    include Celluloid

    attr_accessor :operation_queue

    def initialize(options = {})
      options.each do |attr, value|
        self.send("#{attr.to_s}=", value)
      end
    end

    def operation_queue=(arg)
      @operation_queue = (arg.is_a?(::Proc) ? arg.call : arg)
    end
  
    def execute(*args)
      return false unless @operation_queue && @operation_queue.instantiated?
      @operation_queue.each do |operation|
        operation.execute(*args)
      end
      true
    end
  end
end
