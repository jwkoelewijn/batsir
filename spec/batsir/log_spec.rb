require File.join( File.dirname(__FILE__), "..", "spec_helper" )

describe Batsir::Log do
  it 'provides a convenience method for logging' do
    class TestClass
      include Batsir::Log
    end
    @test = TestClass.new
    @test.log.should be_a Log4r::Logger
  end
end
