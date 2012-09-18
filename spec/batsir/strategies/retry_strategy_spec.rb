require File.join( File.dirname(__FILE__), "..", "..",  "spec_helper" )

describe Batsir::Strategies::RetryStrategy do
  let( :strategy_class ) {
    Batsir::Strategies::RetryStrategy
  }

  before :all do
    class MockError < RuntimeError; end

    class MockRetryContext
      attr_accessor :strategy

      def initialize(failures, retries)
        @total_iterations = 0
        @failures = failures
        @strategy = Batsir::Strategies::RetryStrategy.new(self, retries)
      end

      def execute(message)
        if @total_iterations == @failures
          return "test complete"
        else
          @total_iterations += 1
          handle_error(message)
        end
      end

      def handle_error(message)
        @strategy.execute(message, MockError.new)
      end
    end

    @context = MockRetryContext.new(2,2)
  end

  it 'stores the number of allowed retries' do
    @context.strategy.retries.should == 2
  end

  it 'stores the retry attempts per message' do
    @context.strategy.attempts.should == {}
  end

  it 'attempts to execute the given number of times' do
    @context = MockRetryContext.new(3,3)
    @context.strategy.log.level = Batsir::Logger::SEVERE
    @context.execute("test").should == "test complete"
    @context.strategy.attempts.size.should == 0
  end

  it 'throws an error when all retry attempts have been used' do
    @context = MockRetryContext.new(3,2)
    @context.strategy.log.level = Batsir::Logger::SEVERE
    lambda{@context.execute("test")}.should raise_error Batsir::Errors::RetryStrategyFailed
  end

end
