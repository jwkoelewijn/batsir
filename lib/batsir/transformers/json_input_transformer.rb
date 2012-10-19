module Batsir
  module Transformers
    class JSONInputTransformer < Transformer
      def execute(message)
        begin
          JSON.parse(message, :symbolize_names => false)
        rescue JSON::JSONError => e
          raise Batsir::Errors::JSONInputTransformError.new(e.message)
        end
      end
    end
  end
end
