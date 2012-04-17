require 'sidekiq'

module Batsir
  module StageWorker
    include Sidekiq::Worker

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

      stage.filters.each do |filter, options|
        code << <<-EOF
            @filter_queue.add #{filter.to_s}.new(#{options.to_s})
        EOF
      end

      stage.notifiers.each do |notifier, options|
        code << <<-EOF
            @filter_queue.add_notifier #{notifier.to_s}.new(#{options.to_s})
        EOF
      end

      code << <<-EOF
          end

          include Batsir::StageWorker
        end
      EOF
      code
    end
  end
end
