require File.join( File.dirname(__FILE__), "..", "..",  "spec_helper" )

describe Batsir::Transformers::Transformer do
  let( :transformer_class ) do
    Batsir::Transformers::Transformer
  end

  it "accepts an options hash in its initialiser" do
    transformer_instance = transformer_class.new( {} )
    transformer_instance.should_not be_nil
    transformer_instance.should be_a transformer_class
  end

  it "has a #transform method" do
    transformer_class.instance_methods.map{|m| m.to_s}.should include "transform"
  end

  it "has an #execute method" do
    transformer_class.instance_methods.map{|m| m.to_s}.should include "execute"
  end

  it 'raises an error when the #execute method is not implemented' do
    message = {:foo => :bar}
    lambda{transformer_class.new.transform(message)}.should raise_error NotImplementedError
  end

  it "can transform the message" do
    class Autobot < Batsir::Transformers::Transformer
      def execute(message)
        message = "transform"
      end
    end
    message = {:foo => :bar}
    Autobot.new.transform(message).should == "transform"
  end
end
