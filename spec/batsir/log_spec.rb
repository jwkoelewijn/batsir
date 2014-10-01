require File.join( File.dirname(__FILE__), "..", "spec_helper" )

describe Batsir::Log do
  it 'provides a convenience method for logging' do
    class TestClass
      include Batsir::Log
    end
    expect(TestClass.instance_methods.map{|im| im.to_s}).to include 'log'
  end
end
