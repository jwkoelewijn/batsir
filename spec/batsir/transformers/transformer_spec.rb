require File.join( File.dirname(__FILE__), "..", "..",  "spec_helper" )

describe Batsir::Transformers::Transformer do
  let( :transformer_class ) do
    Batsir::Transformers::Transformer
  end

  it "accepts an options hash in its initialiser" do
    transformer_instance = transformer_class.new( {} )
    expect(transformer_instance).not_to be_nil
    expect(transformer_instance).to be_a transformer_class
  end

  it "has a #transform method" do
    expect(transformer_class.instance_methods.map{|m| m.to_s}).to include "transform"
  end

  it "has an #execute method" do
    expect(transformer_class.instance_methods.map{|m| m.to_s}).to include "execute"
  end

  it 'raises an error when the #execute method is not implemented' do
    message = {:foo => :bar}
    expect{transformer_class.new.transform(message)}.to raise_error NotImplementedError
  end

  it "can transform the message" do
    class Autobot < Batsir::Transformers::Transformer
      def execute(message)
        message = "transform"
      end
    end
    message = {:foo => :bar}
    expect(Autobot.new.transform(message)).to eq("transform")
  end
end
