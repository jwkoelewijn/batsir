module Batsir
  module Notifiers
    class ConditionalNotifier < Notifier
      attr_accessor :notifiers

      NotifierCondition = Struct.new(:condition, :notifier, :options)

      def initialize(options = {})
        super
        @notifiers = []
      end

      def add_notifier( condition, notifier_class, options = {})
        self.notifiers << NotifierCondition.new(condition, notifier_class, options)
      end

      def execute(message)
        self.notifiers.each do |notifier_condition|
          if notifier_condition.condition.call(message)
            notifier = notifier_condition.notifier
            options  = notifier_condition.options
            notifier.notify(message)
          end
        end
        message
      end
    end
  end
end
