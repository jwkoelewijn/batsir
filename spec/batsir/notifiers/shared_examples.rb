shared_examples_for "a notifier" do |notifier_class|
  before :each do
    subject{notifier_class.new}
  end

  context 'transformers' do
    it "has a transformer_queue" do
      expect(subject.transformer_queue).not_to be_nil
    end

    it "initially has an empty transformer_queue" do
      expect(subject.transformer_queue).not_to be_nil
      expect(subject.transformer_queue).to be_empty
    end

    it "can add a transformer to the transformer_queue" do
      transformer = :transformer

      subject.add_transformer transformer

      expect(subject.transformer_queue).not_to be_empty
      expect(subject.transformer_queue.size).to eq(1)
      expect(subject.transformer_queue.first).to eq(:transformer)
    end

    it "can add a transformer multiple times" do
      transformer = :transformer

      subject.add_transformer transformer
      subject.add_transformer transformer

      expect(subject.transformer_queue).not_to be_empty
      expect(subject.transformer_queue.size).to eq(2)
    end

    it "creates a FieldTransformer when the 'fields' option is given during initialization" do
      fields = {:foo => :bar}
      subject = notifier_class.new(:fields => fields)
      expect(subject.transformer_queue).not_to be_empty
      expect(subject.transformer_queue.first.class).to eq(Batsir::Transformers::FieldTransformer)
      expect(subject.transformer_queue.first.fields).to eq(fields)
    end
  end

  context 'methods calls' do
    it "has an #execute method" do
      expect(notifier_class.instance_methods.map{|m| m.to_s}).to include "execute"
    end


    it "calls #transform when #notify is called" do
      allow(subject).to receive(:execute)
      expect(subject).to receive(:transform).with({})
      subject.notify({})
    end

    it "calls #transform on all transformers when #transform is called" do
      class MockTransformer < Batsir::Transformers::Transformer
      end

      allow(subject).to receive(:execute)
      transformer = MockTransformer.new
      subject.add_transformer transformer
      expect(subject.transformer_queue.size).to eq(1)

      expect(transformer).to receive(:transform).with({})
      subject.notify({})
    end

    it "calls #execute when #notify is called" do
      allow(subject).to receive(:execute)
      expect(subject).to receive(:execute)
      subject.notify({})
    end
  end

  context 'message unmodified' do
    it 'has no transformers' do
      message = {'test_id' => 123}
      subject.add_transformer(Batsir::Transformers::JSONOutputTransformer.new)
      begin
        expect(subject.notify(message)).to eq({'test_id' => 123})
      rescue NotImplementedError => e
      end
      expect(message).to eq({'test_id' => 123})
    end

    it 'has a FieldTransformer' do
      fields = {:foo => 'bar', 'test_id' => 'test'}
      message = {'test_id' => 123}
      subject = notifier_class.new(:fields => fields)
      subject.add_transformer(Batsir::Transformers::JSONOutputTransformer.new)
      begin
        expect(subject.notify(message)).to eq({'test_id' => 123})
      rescue NotImplementedError => e
      end
      expect(message).to eq({'test_id' => 123})
    end
  end
end
