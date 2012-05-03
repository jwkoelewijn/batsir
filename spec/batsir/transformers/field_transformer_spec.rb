require File.join( File.dirname(__FILE__), "..", "..",  "spec_helper" )

describe Batsir::Transformers::FieldTransformer do
  let( :transformer_class ) do
    Batsir::Transformers::FieldTransformer
  end

  it "should accept an options hash in its initializer" do
    transformer_instance = transformer_class.new( {} )
    transformer_instance.should_not be_nil
    transformer_instance.should be_a transformer_class
  end


  it "should be possible to set a field mapping using the 'fields' option" do
    field_mapping = {:foo => :bar}
    transformer = transformer_class.new( :fields => field_mapping )
    transformer.fields.should == field_mapping
  end

  it "should use the fields mapping given in an options hash to transform the message using #transform" do
    field_mapping = {:foo => :bar}
    transformer = transformer_class.new( :fields => field_mapping )

    message = {:bar => "bar"}
    transformed_message = transformer.transform(message)
    transformed_message.should have_key :foo
    transformed_message.should_not have_key :bar
    transformed_message[:foo].should == "bar"
  end

  it "should remove options not in the fields option when a fields option is given" do
    field_mapping = {:foo => :bar}
    transformer = transformer_class.new( :fields => field_mapping )

    message = {:bar => "bar", :john => :doe}
    transformed_message = transformer.transform(message)
    transformed_message.should have_key :foo
    transformed_message.should_not have_key :bar
    transformed_message.should_not have_key :john
  end

  it "should not remove fields when no mapping is given" do
    transformer = transformer_class.new

    message = {:bar => "bar", :john => :doe}
    transformed_message = transformer.transform(message)
    transformed_message.should have_key :bar
    transformed_message.should have_key :john
  end

  it "should correctly handle more complex field mapping" do
    field_mapping = {:id => :old_id}
    transformer = transformer_class.new( :fields => field_mapping )

    message = {:id => 2, :old_id => 1, :john => :doe}
    transformed_message = transformer.transform(message)

    transformed_message.should have_key :id
    transformed_message.should_not have_key :old_id
    transformed_message.should_not have_key :john
  end

end
