require File.join( File.dirname(__FILE__), "..", "..", "spec_helper" )

describe Batsir::Transformers::JSONOutputTransformer do
  it "is a Batsir::Transformers::Transformer" do
    subject.should be_a Batsir::Transformers::Transformer
  end

  it "transforms a hash to a valid json hash" do
    some_hash = {:foo => :bar}
    some_hash.should be_a Hash

    result = subject.transform(some_hash)
    result.should be_a String

    result2 = JSON.parse(result)
    result2.should be_a Hash
  end
end
