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
      return false if message.nil?
      return false unless @filter_queue
      @filter_queue.filters.each do |filter|
        message = filter.filter(message)
        return false if message.nil?
      end
      @filter_queue.notifiers.each do |notifier|
        notifier.notify(message)
      end
      true
    end

    def self.compile_from(stage)
      Batsir::Compiler::StageWorkerCompiler.new(stage).compile
    end
  end
end
