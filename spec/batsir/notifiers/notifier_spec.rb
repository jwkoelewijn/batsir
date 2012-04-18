require File.join( File.dirname(__FILE__), "..", "..",  "spec_helper" )

describe Batsir::Notifiers::Notifier do
  let( :notifier_class ) do
    Batsir::Notifiers::Notifier
  end

  it "should accept an options hash in its initializer" do
    notifier_instance = notifier_class.new( {} )
    notifier_instance.should_not be_nil
    notifier_instance.should be_a notifier_class
  end

  it "should be possible to set a field mapping using the 'fields' option" do
    field_mapping = {:foo => :bar}
    notifier = notifier_class.new( :fields => field_mapping )
    notifier.field_mapping.should == field_mapping
  end

  it "should use the fields mapping given in an options hash to transform the message using #transform" do
    field_mapping = {:foo => :bar}
    notifier = notifier_class.new( :fields => field_mapping )

    message = {:bar => "bar"}
    transformed_message = notifier.transform(message)
    transformed_message.should have_key :foo
    transformed_message.should_not have_key :bar
    transformed_message[:foo].should == "bar"
  end

  it "should remove options not in the fields option when a fields option is given" do
    field_mapping = {:foo => :bar}
    notifier = notifier_class.new( :fields => field_mapping )

    message = {:bar => "bar", :john => :doe}
    transformed_message = notifier.transform(message)
    transformed_message.should have_key :foo
    transformed_message.should_not have_key :bar
    transformed_message.should_not have_key :john
  end

  it "should not remove fields when no mapping is given" do
    notifier = notifier_class.new

    message = {:bar => "bar", :john => :doe}
    transformed_message = notifier.transform(message)
    transformed_message.should have_key :bar
    transformed_message.should have_key :john
  end

  it "should call #transform when #notify is called" do
    notifier = notifier_class.new
    notifier.should_receive(:transform).with({})
    notifier.notify({})
  end

  it "should call #execute when #notify is called" do
    notifier = notifier_class.new
    notifier.should_receive(:execute)
    notifier.notify({})
  end
end
