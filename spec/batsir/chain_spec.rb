require File.join( File.dirname(__FILE__), "..", "spec_helper" )

describe Batsir::Chain do
  it "should not be possible to use the constructor" do
    lambda{ Batsir::Chain.new }.should raise_error(NoMethodError)
  end

  it "should return an instance after using the #instance class method" do
    Batsir::Chain.instance.should be_a Batsir::Chain
  end

  it "should return the same instance after the first time" do
    instance = Batsir::Chain.instance
    Batsir::Chain.instance.should == instance
  end

  it "should be possible to reset the instance" do
    instance = Batsir::Chain.instance
    Batsir::Chain.instance.should == instance
    Batsir::Chain.reset!
    Batsir::Chain.instance.should_not == instance
  end

  it "should return same instance for all calls to #instance after a call to #reset!" do
    instance = Batsir::Chain.instance
    Batsir::Chain.instance.should == instance
    Batsir::Chain.reset!
    new_instance = Batsir::Chain.instance
    new_instance.should_not == instance
    Batsir::Chain.instance.should == new_instance
  end

  it "should be possible to set a retrieval operation" do
    operation = "Some retrieval operation"
    chain = Batsir::Chain.instance
    chain.retrieval_operation = operation
    chain.retrieval_operation.should == operation
  end

  it "should be possible to set a persistence operation" do
    operation = "Some retrieval operation"
    chain = Batsir::Chain.instance
    chain.persistence_operation = operation
    chain.persistence_operation.should == operation
  end

  it "should have a list of stages" do
    chain = Batsir::Chain.instance
    chain.stages.should_not be_nil
  end

  it "should initially have an empty list of stages" do
    chain = Batsir::Chain.instance
    chain.stages.should be_empty
  end

  it "should be possible to add a stage" do
    chain = Batsir::Chain.instance
    stage = "stage"
    chain.add_stage(stage)
    chain.stages.should include stage
  end
end
