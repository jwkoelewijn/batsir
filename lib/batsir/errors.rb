module Batsir
  module Errors

    class BatsirError < RuntimeError; end
    class NotifierError < BatsirError; end
    class TransformError < BatsirError; end
    class StrategyError < BatsirError; end

    class ExecuteMethodNotImplementedError < BatsirError; end

    class NotifierConnectionError < NotifierError; end

    class JSONInputTransformError < TransformError; end
    class JSONOutputTransformError < TransformError; end

    class RetryStrategyFailed < StrategyError; end
  end
end
