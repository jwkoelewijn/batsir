require File.join( File.dirname(__FILE__), "..", "spec_helper" )

describe Batsir::Chain do
  it "should be possible to set a retrieval operation" do
    operation = "Some retrieval operation"
    chain = Batsir::Chain.new
    chain.retrieval_operation = operation
    chain.retrieval_operation.should == operation
  end

  it "should be possible to set a retrieval operation using the constructor" do
    operation = "Some retrieval operation"
    chain = Batsir::Chain.new(:retrieval_operation => operation)
    chain.retrieval_operation.should == operation
  end

  it "should be possible to set a persistence operation" do
    operation = "Some persistence operation"
    chain = Batsir::Chain.new
    chain.persistence_operation = operation
    chain.persistence_operation.should == operation
  end

  it "should be possible to set a persistence operation using the constructor" do
    operation = "Some persistence operation"
    chain = Batsir::Chain.new(:persistence_operation => operation)
    chain.persistence_operation.should == operation
  end

  it "should be possible to set a notification operation" do
    operation = "Some notification operation"
    chain = Batsir::Chain.new
    chain.notification_operation = operation
    chain.notification_operation.should == operation
  end

  it "should be possible to set a notification operation using the constructor" do
    operation = "Some notification operation"
    chain = Batsir::Chain.new(:notification_operation => operation)
    chain.notification_operation.should == operation
  end

  it "should have a list of stages" do
    chain = Batsir::Chain.new
    chain.stages.should_not be_nil
  end

  it "should initially have an empty list of stages" do
    chain = Batsir::Chain.new
    chain.stages.should be_empty
  end

  it "should be possible to add a stage" do
    chain = Batsir::Chain.new
    stage = "stage"
    chain.add_stage(stage)
    chain.stages.should include stage
  end
end
