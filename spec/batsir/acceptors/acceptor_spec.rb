require File.join( File.dirname(__FILE__), "..", "..",  "spec_helper" )
require File.join( File.dirname(__FILE__), 'shared_examples')


describe Batsir::Acceptors::Acceptor do
  it_behaves_like "an acceptor", Batsir::Acceptors::Acceptor

  let( :acceptor_class ) {
    Batsir::Acceptors::Acceptor
  }

  it "is a Celluloid actor" do
    expect(acceptor_class.ancestors).to include Celluloid
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
    expect(MockWorker).to receive(:perform_async)
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

    expect(MockTransformer.transformed).to eq(0)

    acceptor.start_filter_chain({})

    expect(MockTransformer.transformed).to eq(1)
  end
end
