module Batsir
  module Notifiers
    class Notifier
      attr_accessor :field_mapping
      attr_accessor :transformer_queue

      def initialize(options = {})
        fields = options.delete(:fields)

        options.each do |option, value|
          self.send("#{option}=", value)
        end
        @transformer_queue = []
        if fields
          add_transformer(Batsir::Transformers::FieldTransformer.new(:fields => fields))
        end
      end

      def add_transformer(transformer)
        @transformer_queue << transformer
      end

      def notify(message)
        original_message = message.clone
        execute(transform(message))
        return original_message
      end

      def transform(message)
        transformer_queue.each do |transformer|
          message = transformer.transform(message)
        end
        message
      end

      def execute(message)
        raise NotImplementedError.new
      end
    end
  end
end
