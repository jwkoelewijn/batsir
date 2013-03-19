module Batsir
  module Transformers
    class FieldTransformer < Transformer
      attr_accessor :fields

      def fields
        @fields ||= {}
      end

      def fields=(hash)
        @fields = {}
        hash.each do |k, v|
          @fields[k.to_sym] = v.to_sym
        end
      end

      def execute(message)
        fields = self.fields
        if fields.any? && message.respond_to?(:keys)
          symbolized_message_keys = {}
          message.keys.each do |key|
            symbolized_message_keys[key.to_sym] = key
          end

          fields_to_remove = symbolized_message_keys.keys - fields.keys - fields.values

          fields.each do |new, old|
            message[new.to_s] = message.delete(symbolized_message_keys[old])
          end

          fields_to_remove.each do |field|
            message.delete(symbolized_message_keys[field])
          end
        end
        message
      end
    end
  end
end
