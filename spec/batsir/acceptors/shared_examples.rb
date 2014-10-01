shared_examples_for "an acceptor" do |acceptor_class|
  before :each do
    subject{acceptor_class.new}
  end

  context 'properties' do
    it "is a Batsir::Acceptors::Acceptor" do
      expect(subject).to be_kind_of Batsir::Acceptors::Acceptor
    end

    it "has a #start method" do
      expect(subject.class.instance_methods.map{|im| im.to_s}).to include "start"
    end

    it "has a #start_filter_chain method" do
      expect(subject.class.instance_methods.map{|im| im.to_s}).to include "start_filter_chain"
    end

    it "has a transformer_queue" do
      expect(subject.transformer_queue).not_to be_nil
    end
  end

  context 'instances' do
    it "can initialize an Acceptor with on options hash" do
      acceptor = acceptor_class.new({})
      expect(acceptor).not_to be_nil
    end

    it "initially has an empty transformer_queue" do
      expect(subject.transformer_queue).not_to be_nil
      expect(subject.transformer_queue).to be_empty
    end

    it "can set the stage name for the acceptor" do
      acceptor = acceptor_class.new
      stage_name = "some stage"
      acceptor.stage_name = stage_name
      expect(acceptor.stage_name).to eq(stage_name)
    end

    it "looks up a worker class when the #start_filter_chain method is called" do
      acceptor = acceptor_class.new
      stage_name = "some stage"
      acceptor.stage_name = stage_name
      expect(Batsir::Registry).to receive(:get).with(stage_name)
      acceptor.start_filter_chain({})
    end
  end

  context 'transformers' do
    it "can add a transformer to the transformer_queue" do
      transformer = :transformer

      acceptor = acceptor_class.new
      acceptor.add_transformer transformer

      expect(acceptor.transformer_queue).not_to be_empty
      expect(acceptor.transformer_queue.size).to eq(1)
      expect(acceptor.transformer_queue.first).to eq(:transformer)
    end

    it "can add a transformer multiple times" do
      transformer = :transformer

      acceptor = acceptor_class.new
      acceptor.add_transformer transformer
      acceptor.add_transformer transformer

      expect(acceptor.transformer_queue).not_to be_empty
      expect(acceptor.transformer_queue.size).to eq(2)
    end

    it "handles errors thrown by transformers" do
      class ErrorAcceptor < Batsir::Acceptors::Acceptor
        attr_accessor :message
        def process_message_error(message, error)
          message = "error"
          @message = message
        end
      end

      class MockTransformer < Batsir::Transformers::Transformer
        def transform(message)
          raise Batsir::Errors::TransformError.new
        end
      end

      acceptor = ErrorAcceptor.new
      stage_name = "some stage"
      acceptor.stage_name = stage_name
      acceptor.add_transformer MockTransformer.new

      expect(acceptor.message).to be_nil

      acceptor.start_filter_chain({})

      expect(acceptor.message).to eq("error")
    end
  end

end
