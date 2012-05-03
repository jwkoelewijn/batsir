module Batsir
  module Transformers
    class FieldTransformer < Transformer
      attr_accessor :fields

      def fields
        @fields ||= {}
      end

      def transform(message)
        fields = self.fields
        if fields.any? && message.respond_to?(:keys)
          fields_to_remove = message.keys - fields.keys - fields.values

          fields.each do |new, old|
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
