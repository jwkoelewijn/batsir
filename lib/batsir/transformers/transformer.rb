module Batsir
  module Transformers
    class Transformer
      def initialize(options = {})
        options.each do |attr, value|
          self.send("#{attr}=", value)
        end
      end

      def transform(message)
        message
      end
    end
  end
end
