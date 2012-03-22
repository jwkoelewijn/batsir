require File.join( File.dirname(__FILE__), "..", "spec_helper" )

describe Batsir::Operation do
  it "should be possible to create an operation" do
    operation = Batsir::Operation.new
    operation.should_not be_nil
  end

  it "should have an #execute method" do
    Batsir::Operation.instance_methods.map{|im| im.to_s}.should include "execute"
  end
end
