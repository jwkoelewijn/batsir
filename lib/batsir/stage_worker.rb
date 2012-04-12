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

    def execute(message)
      puts "No operation queue" unless @operation_queue
      return false unless @operation_queue
      @operation_queue.each do |operation|
        message = operation.execute(message)
        return false if message.nil?
      end
      true
    end
  end
end
