module Batsir
  module Transformers
    class JSONOutputTransformer < Transformer
      def transform(message)
        JSON.dump(message)
      end
    end
  end
end
