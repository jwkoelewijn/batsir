require 'sidekiq'

module Batsir
  module StageWorker

    attr_accessor :operation_queue

    def self.included(base)
      Registry.register(base.stage_name, base)
      base.initialize_operation_queue
    end

    def perform(message)
      puts "Received message in worker"
      execute(message)
    end

    def execute(*args)
      puts "No operation queue" unless @operation_queue
      return false unless @operation_queue
      message = args
      puts args.inspect
      @operation_queue.each do |operation|
        puts "Performing #{operation.class.to_s}"
        message = operation.execute(message)
      end
      puts "Done"
      true
    end
  end
end
