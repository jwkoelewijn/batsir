require File.join( File.dirname(__FILE__), "..", "..", "spec_helper" )

describe Batsir::Transformers::JSONInputTransformer do
  it "should be a Batsir::Transformers::Transformer" do
    subject.should be_a Batsir::Transformers::Transformer
  end

  it "should transform the input to a ruby object" do
    some_json = '{"foo" : "bar"}'
    result = subject.transform(some_json)
    result.should be_a Hash
  end

  it "should transform the input using string names" do
    some_json = '{"foo" : "bar"}'
    result = subject.transform(some_json)

    result[:foo].should be_nil
    result["foo"].should_not be_nil
    result["foo"].should == "bar"
  end
end
