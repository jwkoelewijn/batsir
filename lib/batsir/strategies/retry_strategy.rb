module Batsir
  module Strategies
    class RetryStrategy < Strategy
      include Batsir::Log

      attr_reader :retries, :attempts

      def initialize(context, retries = 3)
        super(context)
        @retries  = retries
        @attempts = {}
      end

      def execute(message, error)
        @attempts[message] ? @attempts[message] += 1 : @attempts[message] = 0

        if @attempts[message] >= @retries
          error_msg = "Tried to send '#{message}' #{@attempts[message]} times and failed"
          reset_attempts(message)
          log.error error_msg
          raise Batsir::Errors::RetryStrategyFailed.new error_msg
        else
          log.warn "Recovering from #{error}. Making another attempt (##{@attempts[message]+1})"
          result = @context.execute(message)
          reset_attempts(message)
          return result
        end
      end

      def reset_attempts(message)
        @attempts.delete(message)
      end
    end
  end
end
