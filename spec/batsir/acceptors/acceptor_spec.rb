require File.join( File.dirname(__FILE__), "..", "..",  "spec_helper" )

describe Batsir::Acceptors::Acceptor do
  let( :acceptor_class ) {
    Batsir::Acceptors::Acceptor
  }

  it "is a Celluloid actor" do
    acceptor_class.ancestors.should include Celluloid
  end

  it "can set the stage name for the acceptor" do
    acceptor = acceptor_class.new
    stage_name = "some stage"
    acceptor.stage_name = stage_name
    acceptor.stage_name.should == stage_name
  end

  it "has a #start method" do
    acceptor_class.instance_methods.map{|im| im.to_s}.should include "start"
  end

  it "has a #start_filter_chain method" do
    acceptor_class.instance_methods.map{|im| im.to_s}.should include "start_filter_chain"
  end

  it "can initialize an Acceptor with on options hash" do
    acceptor = acceptor_class.new({})
    acceptor.should_not be_nil
  end

  it "looks up a worker class when the #start_filter_chain method is called" do
    acceptor = acceptor_class.new
    stage_name = "some stage"
    acceptor.stage_name = stage_name
    Batsir::Registry.should_receive(:get).with(stage_name)
    acceptor.start_filter_chain({})
  end

  it "has a transformer_queue" do
    acceptor = acceptor_class.new
    acceptor.transformer_queue.should_not be_nil
  end

  it "initially has an empty transformer_queue" do
    acceptor = acceptor_class.new
    acceptor.transformer_queue.should_not be_nil
    acceptor.transformer_queue.should be_empty
  end

  it "can add a transformer to the transformer_queue" do
    transformer = :transformer

    acceptor = acceptor_class.new
    acceptor.add_transformer transformer

    acceptor.transformer_queue.should_not be_empty
    acceptor.transformer_queue.size.should == 1
    acceptor.transformer_queue.first.should == :transformer
  end

  it "can add a transformer multiple times" do
    transformer = :transformer

    acceptor = acceptor_class.new
    acceptor.add_transformer transformer
    acceptor.add_transformer transformer

    acceptor.transformer_queue.should_not be_empty
    acceptor.transformer_queue.size.should == 2
  end

  it "can set a cancellator" do
    cancellator = :cancel
    acceptor = acceptor_class.new
    acceptor.cancellator = cancellator
    acceptor.cancellator.should == cancellator
  end

  it "can set a cancellator in the constructor using a hash" do
    cancellator = :cancel
    acceptor = acceptor_class.new(:cancellator => cancellator)
    acceptor.cancellator.should == cancellator
  end

  it "calls the #perform_async on the worker class when #start_filter_chain is called" do
    class MockWorker
      def self.stage_name
        "mock_stage"
      end

      def self.initialize_filter_queue
      end

      def self.perform_async(*args)
      end

      include Batsir::StageWorker
    end

    acceptor = acceptor_class.new
    stage_name = "some stage"

    acceptor.stage_name = stage_name

    Batsir::Registry.register(stage_name, MockWorker)
    MockWorker.should_receive(:perform_async)
    acceptor.start_filter_chain({})
  end

  it "calls #transform on the acceptor transformers" do
    class MockTransformer < Batsir::Transformers::Transformer
      def transform(message)
        @@transformed ||= 0
        @@transformed += 1
      end

      def self.transformed
        @@transformed ||= 0
        @@transformed
      end
    end

    acceptor = acceptor_class.new
    stage_name = "some stage"
    acceptor.stage_name = stage_name
    acceptor.add_transformer MockTransformer.new

    MockTransformer.transformed.should == 0

    acceptor.start_filter_chain({})

    MockTransformer.transformed.should == 1
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

    acceptor.message.should be_nil

    acceptor.start_filter_chain({})

    acceptor.message.should == "error"
  end
end
