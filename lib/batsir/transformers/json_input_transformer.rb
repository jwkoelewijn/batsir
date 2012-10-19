module Batsir
  module Transformers
    class JSONInputTransformer < Transformer
      include Batsir::Log
      def execute(message)
        begin
          JSON.parse(message, :symbolize_names => false)
        rescue JSON::JSONError => e
          log.error "JSONInputTransformError: #{e.message}"
          nil
        end
      end
    end
  end
end
