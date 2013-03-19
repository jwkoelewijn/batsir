require File.join( File.dirname(__FILE__), "..", "..",  "spec_helper" )

describe Batsir::Transformers::FieldTransformer do
  let( :transformer_class ) do
    Batsir::Transformers::FieldTransformer
  end

  it "accepts an options hash in its initializer" do
    transformer_instance = transformer_class.new( {} )
    transformer_instance.should_not be_nil
    transformer_instance.should be_a transformer_class
  end

  it "can set a field mapping using the 'fields' option" do
    field_mapping = {:foo => :bar}
    transformer = transformer_class.new( :fields => field_mapping )
    transformer.fields.should == field_mapping
  end

  it "uses the fields mapping given in an options hash to transform the message using #transform" do
    field_mapping = {:foo => 'bar'}
    transformer = transformer_class.new( :fields => field_mapping )

    message = {'bar' => 123}
    transformed_message = transformer.transform(message)
    transformed_message.should have_key 'foo'
    transformed_message.should_not have_key :foo
    transformed_message.should_not have_key 'bar'
    transformed_message['foo'].should == 123
  end

  it "can use symbols and string based keys and values all the same" do
    field_mapping = {:foo => "bar", "john" => :doe}
    transformer = transformer_class.new( :fields => field_mapping )

    message = {:bar => "foo", "doe" => :john}
    transformed_message = transformer.transform(message)
    transformed_message['foo'].should == 'foo'
    transformed_message['john'].should == :john
  end

  it "removes options not in the fields option when a fields option is given" do
    field_mapping = {:foo => :bar}
    transformer = transformer_class.new( :fields => field_mapping )

    message = {'bar' => "bar", 'john' => :doe}
    transformed_message = transformer.transform(message)
    transformed_message.should have_key 'foo'
    transformed_message.should_not have_key 'bar'
    transformed_message.should_not have_key 'john'
  end

  it "does not remove fields when no mapping is given, but enforces the no_symbol_keys principle" do
    transformer = transformer_class.new

    message = {:bar => "bar", :john => :doe}
    transformed_message = transformer.transform(message)
    transformed_message.should have_key :bar
    transformed_message.should have_key :john
  end

  it "correctly handles more complex field mapping" do
    field_mapping = {:id => :old_id}
    transformer = transformer_class.new( :fields => field_mapping )

    message = {:id => 2, :old_id => 1, :john => :doe}
    transformed_message = transformer.transform(message)

    transformed_message.should have_key 'id'
    transformed_message.should_not have_key 'old_id'
    transformed_message.should_not have_key 'john'
  end
end
