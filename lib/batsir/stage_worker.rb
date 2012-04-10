require 'sidekiq'

module Batsir
  module StageWorker

    attr_accessor :operation_queue

    def self.included(base)
      Registry.register(base.stage_name, base)
      base.initialize_operation_queue
    end

    def perform(message)
      execute(message)
    end

    def execute(*args)
      return false unless @operation_queue
      message = *args
      @operation_queue.each do |operation|
        message = operation.execute(message)
      end
      true
    end
  end
end
