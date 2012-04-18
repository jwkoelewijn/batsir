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
        if @field_mapping.any? && message.respond_to?(:keys)
          fields_to_remove = message.keys - @field_mapping.keys - @field_mapping.values

          @field_mapping.each do |new, old|
            message[new] = message.delete(old)
          end

          fields_to_remove.each do |field|
            message.delete(field)
          end
        end
        message
      end
    end
  end
end
