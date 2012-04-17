module Batsir
  class FilterQueue
    include Enumerable

    attr_accessor :operations
    attr_accessor :notifiers

    def initialize
      @operations = []
      @notifiers = []
      @notification_operations = []
    end

    def add(operation)
      @operations.unshift(operation)
    end

    def add_notifier(notifier)
      @notifiers << notifier
    end

    def each
      @operations.each {|op| yield op}
      @notifiers.each {|n| yield n}
    end

    def empty?
      !(@notifiers.any? || @operations.any?)
    end

    def generate_code_for(stage)
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
              @filter_queue = #{self.class.to_s}.new
      EOF

      self.operations.each do |operation|
        code << <<-EOF
              @filter_queue.add #{operation.to_s}.new
        EOF
      end

      stage.notifiers.each do |notifier_class, options|
        code << <<-EOF
              @filter_queue.add_notifier #{notifier_class.to_s}.new(#{options})
        EOF
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
