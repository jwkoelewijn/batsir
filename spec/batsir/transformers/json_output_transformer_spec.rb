require File.join( File.dirname(__FILE__), "..", "..", "spec_helper" )

describe Batsir::Transformers::JSONOutputTransformer do
  it "is a Batsir::Transformers::Transformer" do
    expect(subject).to be_a Batsir::Transformers::Transformer
  end

  it "transforms a hash to a valid json hash" do
    some_hash = {:foo => :bar}
    expect(some_hash).to be_a Hash

    result = subject.transform(some_hash)
    expect(result).to be_a String

    result2 = JSON.parse(result)
    expect(result2).to be_a Hash
  end
end
