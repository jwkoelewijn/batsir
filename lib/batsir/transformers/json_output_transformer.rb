module Batsir
  module Transformers
    class JSONOutputTransformer < Transformer
      def execute(message)
        begin
          JSON.dump(message)
        rescue JSON::JSONError => e
          raise Batsir::Errors::JSONOutputTransformError.new(e.message)
        end
      end
    end
  end
end
