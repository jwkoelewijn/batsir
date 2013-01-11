shared_examples_for "a notifier" do |notifier_class|
  before :each do
    subject{notifier_class.new}
  end

  context 'transformers' do
    it "has a transformer_queue" do
      subject.transformer_queue.should_not be_nil
    end

    it "initially has an empty transformer_queue" do
      subject.transformer_queue.should_not be_nil
      subject.transformer_queue.should be_empty
    end

    it "can add a transformer to the transformer_queue" do
      transformer = :transformer

      subject.add_transformer transformer

      subject.transformer_queue.should_not be_empty
      subject.transformer_queue.size.should == 1
      subject.transformer_queue.first.should == :transformer
    end

    it "can add a transformer multiple times" do
      transformer = :transformer

      subject.add_transformer transformer
      subject.add_transformer transformer

      subject.transformer_queue.should_not be_empty
      subject.transformer_queue.size.should == 2
    end

    it "creates a FieldTransformer when the 'fields' option is given during initialization" do
      fields = {:foo => :bar}
      subject = notifier_class.new(:fields => fields)
      subject.transformer_queue.should_not be_empty
      subject.transformer_queue.first.class.should == Batsir::Transformers::FieldTransformer
      subject.transformer_queue.first.fields.should == fields
    end
  end

  context 'methods calls' do
    it "has an #execute method" do
      notifier_class.instance_methods.map{|m| m.to_s}.should include "execute"
    end


    it "calls #transform when #notify is called" do
      subject.stub(:execute)
      subject.should_receive(:transform).with({})
      subject.notify({})
    end

    it "calls #transform on all transformers when #transform is called" do
      class MockTransformer < Batsir::Transformers::Transformer
      end

      subject.stub(:execute)
      transformer = MockTransformer.new
      subject.add_transformer transformer
      subject.transformer_queue.size.should == 1

      transformer.should_receive(:transform).with({})
      subject.notify({})
    end

    it "calls #execute when #notify is called" do
      subject.stub(:execute)
      subject.should_receive(:execute)
      subject.notify({})
    end
  end

  context 'message unmodified' do
    it 'has no transformers' do
      begin
        subject.notify({'test_id' => 123}).should == {'test_id' => 123}
      rescue NotImplementedError => e
      end
    end

    it 'has a FieldTransformer' do
      fields = {:foo => 'bar'}
      subject = notifier_class.new(:fields => fields)
      begin
        subject.notify({'test_id' => 123}).should == {'test_id' => 123}
      rescue NotImplementedError => e
      end
    end
  end
end
