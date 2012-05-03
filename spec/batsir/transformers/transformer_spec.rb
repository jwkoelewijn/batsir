require File.join( File.dirname(__FILE__), "..", "..",  "spec_helper" )

describe Batsir::Transformers::Transformer do
  let( :transformer_class ) do
    Batsir::Transformers::Transformer
  end

  it "should accept an options hash in its initializer" do
    transformer_instance = transformer_class.new( {} )
    transformer_instance.should_not be_nil
    transformer_instance.should be_a transformer_class
  end

  it "should have a #transform method" do
    transformer_class.instance_methods.map{|m| m.to_s}.should include "transform"
  end

  it "should return the message by default" do
    message = {:foo => :bar}
    transformer_class.new.transform(message).should == message
  end
end
