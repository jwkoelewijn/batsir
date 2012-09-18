module Batsir
  module Strategies
    class Strategy

      attr_reader :context

      def initialize(context)
        if context.respond_to? :execute
          @context = context
        else
          raise Batsir::Errors::ExecuteMethodNotImplementedError.new
        end
      end

      def execute(message, error = nil)
      end

    end
  end
end
