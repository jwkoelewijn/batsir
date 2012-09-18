require File.join( File.dirname(__FILE__), "..", "..",  "spec_helper" )

describe Batsir::Strategies::Strategy do
  let( :strategy_class ) {
    Batsir::Strategies::Strategy
  }

  class MockContext
    def execute(message)
    end
  end

  class DefunctMockContext; end

  it 'has an #execute method' do
    strategy_class.instance_methods.map{|im| im.to_s}.should include "execute"
  end

  it 'has an accessable context' do
    c = MockContext.new
    strategy_class.new(c).context.should == c
  end

  it 'detects an incorrect context object being passed' do
    c = DefunctMockContext.new
    lambda{strategy_class.new(c)}.should raise_error Batsir::Errors::ExecuteMethodNotImplementedError
  end
end
