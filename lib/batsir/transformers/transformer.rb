module Batsir
  module Transformers
    class Transformer
      def initialize(options = {})
        options.each do |attr, value|
          self.send("#{attr}=", value)
        end
      end

      def transform(message)
        execute(message)
      end

      def execute(message)
        raise NotImplementedError.new
      end
    end
  end
end
