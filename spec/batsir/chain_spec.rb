require File.join( File.dirname(__FILE__), "..", "spec_helper" )

describe Batsir::Chain do
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
    stage = Batsir::Stage.new(:name => "Stage")
    chain.add_stage(stage)
    chain.stages.should include stage
  end

  it "should be possible to compile a chain" do
    chain = Batsir::Chain.new
    stage = Batsir::Stage.new(:name => "Stage")
    chain.add_stage(stage)
    compiled_code = chain.compile
    compiled_code.should_not be_nil

    klazz = eval(compiled_code)
    klazz.name.to_s.should == "StageWorker"
  end
end
