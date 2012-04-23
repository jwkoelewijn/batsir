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
      return false unless @filter_queue
      @filter_queue.filters.each do |filter|
        message = filter.execute(message)
        return false if message.nil?
      end
      @filter_queue.notifiers.each do |notifier|
        notifier.notify(message)
      end
      true
    end

    def self.compile_from(stage)
      code = <<-EOF
        class #{stage.name.capitalize.gsub(' ','')}Worker
          def self.stage_name
            "#{stage.name}"
          end

          def initialize
            @filter_queue = self.class.filter_queue
          end

          def self.filter_queue
            @filter_queue
          end

          def self.initialize_filter_queue
            @filter_queue = Batsir::FilterQueue.new
      EOF

      stage.filter_declarations.each do |filter_declaration|
        code << <<-EOF
            @filter_queue.add #{filter_declaration.filter.to_s}.new(#{filter_declaration.options.to_s})
        EOF
      end

      stage.notifiers.each do |notifier, options_set|
        options_set.each do |options|
          code << <<-EOF
            @filter_queue.add_notifier #{notifier.to_s}.new(#{options.to_s})
          EOF
        end
      end

      code << <<-EOF
          end

          include Sidekiq::Worker
          include Batsir::StageWorker
        end
      EOF
      code
    end
  end
end
