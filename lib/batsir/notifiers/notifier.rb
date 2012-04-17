module Batsir
  module Notifiers
    class Notifier
      attr_accessor :field_mapping

      def initialize(options = {})
        @field_mapping = options.delete(:fields) || {}
        options.each do |option, value|
          self.send("#{option}=", value)
        end
      end

      def notify(message)
        execute(transform(message))
      end

      def execute(message)

      end

      def transform(message)
        @field_mapping.each do |new, old|
          message[new] = message.delete(old)
        end
        message
      end
    end
  end
end
