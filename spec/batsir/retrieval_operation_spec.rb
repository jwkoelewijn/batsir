require File.join( File.dirname(__FILE__), "..", "spec_helper")

describe Batsir::RetrievalOperation do
  it "should respond to #execute" do
    Batsir::RetrievalOperation.instance_methods.map{|im| im.to_s}.should include "execute"
  end

  it "should be possible to set the object type for the retrieval operation" do
    object_type = Object
    operation = Batsir::RetrievalOperation.new
    operation.object_type = object_type
    operation.object_type.should == object_type
  end
end
