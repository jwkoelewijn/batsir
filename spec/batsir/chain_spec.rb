require File.join( File.dirname(__FILE__), "..", "spec_helper" )

describe Batsir::Chain do
  it "has a list of stages" do
    chain = Batsir::Chain.new
    expect(chain.stages).not_to be_nil
  end

  it "initially has an empty list of stages" do
    chain = Batsir::Chain.new
    expect(chain.stages).to be_empty
  end

  it "can add a stage" do
    chain = Batsir::Chain.new
    stage = Batsir::Stage.new(:name => "Stage")
    chain.add_stage(stage)
    expect(chain.stages).to include stage
  end

  it "can compile a chain" do
    chain = Batsir::Chain.new
    stage = Batsir::Stage.new(:name => "Stage")
    chain.add_stage(stage)
    compiled_code = chain.compile
    expect(compiled_code).not_to be_nil

    klazz = eval(compiled_code)
    expect(klazz.name.to_s).to eq("StageWorker")
  end
end
