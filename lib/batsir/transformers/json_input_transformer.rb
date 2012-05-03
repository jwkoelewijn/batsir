module Batsir
  module Transformers
    class JSONInputTransformer < Transformer
      def transform(message)
        JSON.parse(message, :symbolize_names => true)
      end
    end
  end
end
