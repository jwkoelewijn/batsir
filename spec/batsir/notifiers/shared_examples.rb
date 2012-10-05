shared_examples_for "notifier" do |notifier_class|
  it "has a transformer_queue" do
    notifier = notifier_class.new
    notifier.transformer_queue.should_not be_nil
  end

  it "initially has an empty transformer_queue" do
    notifier = notifier_class.new
    notifier.transformer_queue.should_not be_nil
    notifier.transformer_queue.should be_empty
  end

  it "can add a transformer to the transformer_queue" do
    transformer = :transformer

    notifier = notifier_class.new
    notifier.add_transformer transformer

    notifier.transformer_queue.should_not be_empty
    notifier.transformer_queue.size.should == 1
    notifier.transformer_queue.first.should == :transformer
  end

  it "can add a transformer multiple times" do
    transformer = :transformer

    notifier = notifier_class.new
    notifier.add_transformer transformer
    notifier.add_transformer transformer

    notifier.transformer_queue.should_not be_empty
    notifier.transformer_queue.size.should == 2
  end

  it "creates a FieldTransformer when the 'fields' option is given during initialization" do
    fields = {:foo => :bar}
    notifier = notifier_class.new(:fields => fields)
    notifier.transformer_queue.should_not be_empty
    notifier.transformer_queue.first.class.should == Batsir::Transformers::FieldTransformer
    notifier.transformer_queue.first.fields.should == fields
  end

  it "has an #execute method" do
    notifier_class.instance_methods.map{|m| m.to_s}.should include "execute"
  end

  
  it "calls #transform when #notify is called" do
    notifier = notifier_class.new
    notifier.stub(:execute)
    notifier.should_receive(:transform).with({})
    notifier.notify({})
  end

  it "calls #transform on all transformers when #transform is called" do
    class MockTransformer < Batsir::Transformers::Transformer
    end

    notifier = notifier_class.new
    notifier.stub(:execute)
    transformer = MockTransformer.new
    notifier.add_transformer transformer
    notifier.transformer_queue.size.should == 1

    transformer.should_receive(:transform).with({})
    notifier.notify({})
  end

  it "calls #execute when #notify is called" do
    notifier = notifier_class.new
    notifier.stub(:execute)
    notifier.should_receive(:execute)
    notifier.notify({})
  end
end
