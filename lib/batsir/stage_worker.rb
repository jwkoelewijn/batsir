require 'sidekiq'

module Batsir
  module StageWorker

    attr_accessor :filter_queue

    def self.included(base)
      Registry.register(base.stage_name, base)
      base.initialize_filter_queue
    end

    def perform(message)
      execute(message)
    end

    def execute(message)
      puts "No filter queue" unless @filter_queue
      return false unless @filter_queue
      @filter_queue.each do |filter|
        message = filter.execute(message)
        return false if message.nil?
      end
      true
    end
  end
end
