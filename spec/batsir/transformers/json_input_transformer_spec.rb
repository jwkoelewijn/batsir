require File.join( File.dirname(__FILE__), "..", "..", "spec_helper" )

describe Batsir::Transformers::JSONInputTransformer do
  it "is a Batsir::Transformers::Transformer" do
    expect(subject).to be_a Batsir::Transformers::Transformer
  end

  it "transforms the input to a ruby object" do
    some_json = '{"foo" : "bar"}'
    result = subject.transform(some_json)
    expect(result).to be_a Hash
  end

  it "transforms the input using string names" do
    some_json = '{"foo" : "bar"}'
    result = subject.transform(some_json)

    expect(result[:foo]).to be_nil
    expect(result["foo"]).not_to be_nil
    expect(result["foo"]).to eq("bar")
  end

  it "should throw a TransformError when the input is malformed" do
    test = Batsir::Transformers::JSONInputTransformer.new
    expect{ test.transform("1") }.to raise_error Batsir::Errors::TransformError
  end
end
