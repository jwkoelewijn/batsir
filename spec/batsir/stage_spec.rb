require File.join( File.dirname(__FILE__), "..", "spec_helper" )

describe Batsir::Stage do
  def create_stage(options = {})
    defaults = {
      :name   => "Test Stage",
      :chain  => Batsir::Chain.new
    }
    Batsir::Stage.new(defaults.merge(options))
  end

  before :all do
    class StubFilter < Batsir::Filter
    end

    class AnotherFilter < Batsir::Filter
    end

    @object_type = "SomeResource"
  end

  it "is a Celluloid Actor" do
    expect(Batsir::Stage.ancestors).to include Celluloid
  end

  it "can name the stage" do
    stage = Batsir::Stage.new
    name = "StageName"
    stage.name = name
    expect(stage.name).to eq(name)
  end

  it "can set the name in the constructor" do
    name = "StageName"
    stage = Batsir::Stage.new(:name => name)
    expect(stage.name).to eq(name)
  end

  it "can set the aggregator chain to which the stage belongs" do
    chain = "Chain"
    stage = Batsir::Stage.new(:chain => chain)
    expect(stage.chain).to eq(chain)
  end

  context "with respect to filters" do
    it "cannot set the filters directly" do
      stage = Batsir::Stage.new
      expect { stage.filters = {} }.to raise_error(NoMethodError)
    end

    it "stores filters using filter declarations" do
      filter = "Filter"
      stage = Batsir::Stage.new
      stage.add_filter(filter)
      expect(stage.filter_declarations).not_to be_nil
      expect(stage.filter_declarations.size).to eq(1)
      declaration = stage.filter_declarations.first
      expect(declaration.filter).to eq(filter)
      expect(declaration.options).to eq({})
    end

    it "returns an empty array when the #filters method is called without any declared filters" do
      stage = Batsir::Stage.new
      expect(stage.filters).not_to be_nil
      expect(stage.filters).to eq([])
    end

    it "returns all filters when the #filters method is called" do
      filter1 = "Filter"
      filter2 = "Filter2"
      filter3 = "Filter"
      stage = Batsir::Stage.new
      stage.add_filter(filter1)
      stage.add_filter(filter2)
      stage.add_filter(filter3)

      expect(stage.filters).not_to be_nil
      expect(stage.filters.size).to eq(3)
      expect(stage.filters[0]).to eq(filter1)
      expect(stage.filters[1]).to eq(filter2)
      expect(stage.filters[2]).to eq(filter3)
    end

    it "adds a filter to its filters" do
      filter = "Filter"
      stage = Batsir::Stage.new
      stage.add_filter(filter)
      expect(stage.filters).not_to be_nil
      expect(stage.filters).to include filter
    end

    it "can have multiple filters of the same class but with different options" do
      stage = Batsir::Stage.new
      stage.add_filter(:filter)
      stage.add_filter(:filter, :foo => :bar)

      expect(stage.filters).to include :filter
      expect(stage.filters.size).to eq(2)
    end

    it "can add filters with on options hash" do
      filter = :filter
      options = {:foo => :bar}

      stage = Batsir::Stage.new
      stage.add_filter(filter, options)

      expect(stage.filters).not_to be_nil
      expect(stage.filters).not_to be_empty
      expect(stage.filters).to include filter
      expect(stage.filter_declarations.first.options).to eq(options)
    end

    it "can add multiple filters with option hashes" do
      filter1 = :filter1
      filter2 = :filter2
      options1 = {:foo1 => :bar1}
      options2 = {:foo2 => :bar2}

      stage = Batsir::Stage.new
      stage.add_filter(filter1, options1)
      stage.add_filter(filter2, options2)

      expect(stage.filters).to include filter1
      expect(stage.filters).to include filter2
      expect(stage.filter_declarations[0].options).to eq(options1)
      expect(stage.filter_declarations[1].options).to eq(options2)
    end

    it "adds empty options hashes to filters when no option hash is given" do
      filter = :filter

      stage = Batsir::Stage.new
      stage.add_filter(filter)

      expect(stage.filters).not_to be_nil
      expect(stage.filters).not_to be_empty
      expect(stage.filters).to include filter
      expect(stage.filter_declarations.first.options).to eq({})
    end

    it "can add a filter more than once" do
      filter = :filter
      stage = Batsir::Stage.new
      stage.add_filter(filter)
      stage.add_filter(filter)
      expect(stage.filters).not_to be_nil
      expect(stage.filters).not_to be_empty
      expect(stage.filters.size).to eq(2)
    end

    it "can add filter with different options and respect the order" do
      filter = :filter
      other_filter = :other_filter

      stage = Batsir::Stage.new
      stage.add_filter(filter)
      stage.add_filter(other_filter)
      stage.add_filter(filter, :foo => :bar)
      expect(stage.filters.size).to eq(3)
    end
  end

  context "with respect to acceptors" do
    it "initially has an empty list of acceptors" do
      stage = Batsir::Stage.new
      expect(stage.acceptors).not_to be_nil
      expect(stage.acceptors).to be_empty
    end

    it "cannot set the acceptors directly" do
      stage = Batsir::Stage.new
      expect { stage.acceptors = {} }.to raise_error(NoMethodError)
    end

    it "can add new acceptors" do
      stage = Batsir::Stage.new
      stage.add_acceptor(:acceptor)
      expect(stage.acceptors).not_to be_nil
      expect(stage.acceptors).not_to be_empty
      expect(stage.acceptors.keys).to include :acceptor
    end

    it "stores a set of different options for each acceptor" do
      stage = Batsir::Stage.new
      stage.add_acceptor(:acceptor)
      expect(stage.acceptors[:acceptor]).to be_a Set
    end

    it "can have multiple acceptors of the same class but with different options" do
      stage = Batsir::Stage.new
      stage.add_acceptor(:acceptor_class)
      stage.add_acceptor(:acceptor_class, :foo => :bar)

      expect(stage.acceptors).not_to be_nil
      expect(stage.acceptors).not_to be_empty
      expect(stage.acceptors.keys).to include :acceptor_class
      expect(stage.acceptors[:acceptor_class].size).to eq(2)
    end

    it "can add an acceptor with an options hash" do
      stage = Batsir::Stage.new
      options = {:foo => :bar}
      stage.add_acceptor(:acceptor, options)

      expect(stage.acceptors).not_to be_nil
      expect(stage.acceptors).not_to be_empty
      expect(stage.acceptors.keys).to include :acceptor
      expect(stage.acceptors[:acceptor].first).to eq(options)
    end

    it "adds an empty options hash for added acceptors without options" do
      stage = Batsir::Stage.new
      stage.add_acceptor(:acceptor)

      expect(stage.acceptors).not_to be_nil
      expect(stage.acceptors).not_to be_empty
      expect(stage.acceptors.keys).to include :acceptor
      expect(stage.acceptors[:acceptor].first).to eq({})
    end

    it "initially has an empty list of cancellators" do
      stage = Batsir::Stage.new
      expect(stage.cancellators).not_to be_nil
      expect(stage.cancellators).to be_empty
    end

    context "with respect to acceptor transformers" do
      it "has an empty acceptor transformers queue by default" do
        stage = Batsir::Stage.new

        expect(stage.acceptor_transformers).not_to be_nil
        expect(stage.acceptor_transformers).to be_empty
      end

      it "can add a transformer to the acceptors" do
        stage = Batsir::Stage.new

        transformer = :transformer

        stage.add_acceptor_transformer(transformer)
        expect(stage.acceptor_transformers).not_to be_empty

        expect(stage.acceptor_transformers.first.transformer).to eq(transformer)
      end

      it "adds an empty options hash by default" do
        stage = Batsir::Stage.new

        transformer = :transformer
        stage.add_acceptor_transformer(transformer)
        expect(stage.acceptor_transformers).not_to be_empty

        expect(stage.acceptor_transformers.first.options).to eq({})
      end

      it "can add options to a transformer" do
        stage = Batsir::Stage.new

        transformer = :transformer
        options = {:foo => :bar}

        stage.add_acceptor_transformer(transformer, options)
        expect(stage.acceptor_transformers).not_to be_empty

        expect(stage.acceptor_transformers.first.transformer).to eq(transformer)
        expect(stage.acceptor_transformers.first.options).to eq(options)
      end

      it "can add multiple transformers" do
        stage = Batsir::Stage.new

        transformer1 = :transformer1
        transformer2 = :transformer2

        stage.add_acceptor_transformer(transformer1)
        stage.add_acceptor_transformer(transformer2)
        expect(stage.acceptor_transformers).not_to be_empty
        expect(stage.acceptor_transformers.size).to eq(2)

        transformers = stage.acceptor_transformers.map{|td| td.transformer}
        expect(transformers).to include transformer1
        expect(transformers).to include transformer2
      end

      it "keeps the transformers in the order of declaration" do
        stage = Batsir::Stage.new

        transformer1 = :transformer1
        transformer2 = :transformer2

        stage.add_acceptor_transformer(transformer1)
        stage.add_acceptor_transformer(transformer2)
        expect(stage.acceptor_transformers).not_to be_empty
        expect(stage.acceptor_transformers.size).to eq(2)

        expect(stage.acceptor_transformers.first.transformer).to eq(transformer1)
        expect(stage.acceptor_transformers.last.transformer).to eq(transformer2)
      end

      it "can add a transformer more than once" do
        stage = Batsir::Stage.new

        transformer = :transformer

        stage.add_acceptor_transformer(transformer)
        stage.add_acceptor_transformer(transformer)
        expect(stage.acceptor_transformers).not_to be_empty
        expect(stage.acceptor_transformers.size).to eq(2)

        expect(stage.acceptor_transformers.first.transformer).to eq(transformer)
        expect(stage.acceptor_transformers.last.transformer).to eq(transformer)
      end
    end
  end


  context "with respect to notifiers" do
    it "initially has an empty notifiers queue" do
      stage = Batsir::Stage.new
      expect(stage.notifiers).not_to be_nil
      expect(stage.notifiers).to be_empty
    end

    it "cannot set the notifiers directly" do
      stage = Batsir::Stage.new
      expect { stage.notifiers = {} }.to raise_error(NoMethodError)
    end

    it "can add new notifiers" do
      stage = Batsir::Stage.new

      stage.add_notifier(:notifier)
      expect(stage.notifiers).not_to be_nil
      expect(stage.notifiers).not_to be_empty
      expect(stage.notifiers.keys).to include :notifier
    end

    it "stores a set of different options for each notifier" do
      stage = Batsir::Stage.new
      stage.add_notifier(:notifier)
      expect(stage.notifiers[:notifier]).to be_a Set
    end

    it "can have multiple notifiers of the same class but with different options" do
      stage = Batsir::Stage.new
      stage.add_notifier(:notifier_class)
      stage.add_notifier(:notifier_class, :foo => :bar)

      expect(stage.notifiers).not_to be_nil
      expect(stage.notifiers.keys).to include :notifier_class
      expect(stage.notifiers[:notifier_class].size).to eq(2)
    end

    it "can set a notifier with an options hash" do
      stage = Batsir::Stage.new

      options = {:foo => :bar}

      stage.add_notifier(:notifier, options)
      expect(stage.notifiers).not_to be_nil
      expect(stage.notifiers).not_to be_empty
      expect(stage.notifiers.keys).to include :notifier
      expect(stage.notifiers[:notifier].first).to eq(options)
    end

    it "adds an empty options hash for added notifiers without options" do
      stage = Batsir::Stage.new

      stage.add_notifier(:notifier)
      expect(stage.notifiers).not_to be_nil
      expect(stage.notifiers).not_to be_empty
      expect(stage.notifiers.keys).to include :notifier
      expect(stage.notifiers[:notifier].first).to eq({})
    end

    context "with respect to notifier transformers" do
      it "has an empty notifier transformers queue by default" do
        stage = Batsir::Stage.new

        expect(stage.notifier_transformers).not_to be_nil
        expect(stage.notifier_transformers).to be_empty
      end

      it "can add a transformer to the notifiers" do
        stage = Batsir::Stage.new

        transformer = :transformer

        stage.add_notifier_transformer(transformer)
        expect(stage.notifier_transformers).not_to be_empty

        expect(stage.notifier_transformers.first.transformer).to eq(transformer)
      end

      it "adds an empty options hash by default" do
        stage = Batsir::Stage.new

        transformer = :transformer
        stage.add_notifier_transformer(transformer)
        expect(stage.notifier_transformers).not_to be_empty

        expect(stage.notifier_transformers.first.options).to eq({})
      end

      it "can add options to a transformer" do
        stage = Batsir::Stage.new

        transformer = :transformer
        options = {:foo => :bar}

        stage.add_notifier_transformer(transformer, options)
        expect(stage.notifier_transformers).not_to be_empty

        expect(stage.notifier_transformers.first.transformer).to eq(transformer)
        expect(stage.notifier_transformers.first.options).to eq(options)
      end

      it "can add multiple transformers" do
        stage = Batsir::Stage.new

        transformer1 = :transformer1
        transformer2 = :transformer2

        stage.add_notifier_transformer(transformer1)
        stage.add_notifier_transformer(transformer2)
        expect(stage.notifier_transformers).not_to be_empty
        expect(stage.notifier_transformers.size).to eq(2)

        transformers = stage.notifier_transformers.map{|td| td.transformer}
        expect(transformers).to include transformer1
        expect(transformers).to include transformer2
      end

      it "keeps the transformers in the order of declaration" do
        stage = Batsir::Stage.new

        transformer1 = :transformer1
        transformer2 = :transformer2

        stage.add_notifier_transformer(transformer1)
        stage.add_notifier_transformer(transformer2)
        expect(stage.notifier_transformers).not_to be_empty
        expect(stage.notifier_transformers.size).to eq(2)

        expect(stage.notifier_transformers.first.transformer).to eq(transformer1)
        expect(stage.notifier_transformers.last.transformer).to eq(transformer2)
      end

      it "can add a transformer more than once" do
        stage = Batsir::Stage.new

        transformer = :transformer

        stage.add_notifier_transformer(transformer)
        stage.add_notifier_transformer(transformer)
        expect(stage.notifier_transformers).not_to be_empty
        expect(stage.notifier_transformers.size).to eq(2)

        expect(stage.notifier_transformers.first.transformer).to eq(transformer)
        expect(stage.notifier_transformers.last.transformer).to eq(transformer)
      end
    end
  end

  context "with respect to conditional notifiers" do
    it "initially has an empty conditional notifiers queue" do
      stage = Batsir::Stage.new
      expect(stage.conditional_notifiers).not_to be_nil
      expect(stage.conditional_notifiers).to be_empty
    end

    it "cannot set the conditional notifiers directly" do
      stage = Batsir::Stage.new
      expect { stage.conditional_notifiers = {} }.to raise_error(NoMethodError)
    end

    it "can add new conditional notifiers" do
      stage = Batsir::Stage.new

      stage.add_conditional_notifier(:notifier)
      expect(stage.conditional_notifiers).not_to be_nil
      expect(stage.conditional_notifiers).not_to be_empty
    end
  end

  context "with respect to compiling the stage" do
    before :all do
      @stage_name = "Stage 1"

      Celluloid.boot

      stage = Batsir::Stage.new(:name => @stage_name)

      stage.add_notifier_transformer(Batsir::Transformers::Transformer)
      stage.add_notifier(Batsir::Notifiers::Notifier)
      stage.add_filter(Batsir::Filter)
      stage.add_filter(Batsir::Filter)

      @created_class = eval( stage.compile )
    end

    it "creates a class named after the stage name" do
      expect(@created_class.to_s).to eq("Stage1Worker")
    end

    it "creates a Batsir::StageWorker class" do
      expect(@created_class.ancestors).to include Batsir::StageWorker
    end

    it "creates a class that includes Sidekiq::Worker" do
      expect(@created_class.ancestors).to include Sidekiq::Worker
    end

    it "creates a worker class named after the stage name" do
      expect(@created_class.stage_name).to eq(@stage_name)
    end

    it "adds the notifier during compilation" do
      instance = @created_class.new
      expect(instance.filter_queue.notifiers).not_to be_nil
      expect(instance.filter_queue.notifiers).not_to be_empty
      expect(instance.filter_queue.notifiers.size).to eq(1)
      expect(instance.filter_queue.notifiers.first).to be_a Batsir::Notifiers::Notifier
    end

    it "adds a transformer to the notifier during compilation" do
      instance = @created_class.new

      expect(instance.filter_queue.notifiers.first.transformer_queue).not_to be_empty
      expect(instance.filter_queue.notifiers.first.transformer_queue.first).to be_a Batsir::Transformers::Transformer
    end

    it "adds a JSONOutputTransformer by default when no transformers are defined" do
      stage = Batsir::Stage.new(:name => "SomeName")

      stage.add_notifier(Batsir::Notifiers::Notifier)

      created_class = eval( stage.compile )
      instance = created_class.new

      expect(instance.filter_queue.notifiers).not_to be_nil
      expect(instance.filter_queue.notifiers).not_to be_empty
      expect(instance.filter_queue.notifiers.first.transformer_queue).not_to be_empty
      expect(instance.filter_queue.notifiers.first.transformer_queue.first).to be_a Batsir::Transformers::JSONOutputTransformer
    end

    it "initialises a class local filter queue" do
      expect(@created_class.filter_queue).not_to be_nil
      expect(@created_class.filter_queue).not_to be_empty
    end

    it "has intitialized the filters" do
      expect(@created_class.filter_queue.map{|filter| filter.class.to_s}).to include "Batsir::Filter"
    end

    it "can add a filter multiple times" do
      expect(@created_class.filter_queue.select{ |filter| filter.class == Batsir::Filter }.size).to eq(2)
    end

    it "uses the class local filter queue once an instance is initialized" do
      instance = @created_class.new
      expect(instance.filter_queue).to eq(@created_class.filter_queue)
    end

    it "initialises all filters in the filter queue" do
      @created_class.filter_queue.each do |filter|
        expect(filter).not_to be_a Class
      end
    end
  end

  context "with respect to starting the stage" do
    before :all do
      class MockAcceptor < Batsir::Acceptors::Acceptor

        def foo=(bar)
        end

        def stage_name=(name)
          @@stage_name = name
        end

        def self.stage_name
          @@stage_name
        end

        def start
          @@start_count ||= 0
          @@start_count += 1
        end

        def add_transformer(transformer)
          @@added_transformers ||= []
          @@added_transformers << transformer
        end

        def self.added_transformers
          @@added_transformers ||= []
        end

        def self.start_count
          @@start_count ||= 0
        end

        def self.reset
          @@start_count = 0
          @@stage_name = nil
          @@added_transformers = []
        end

      end

      class Celluloid::ActorProxy
        def start!
          Celluloid::Actor.call @mailbox, :start
        end
      end
    end

    before :each do
      MockAcceptor.reset
    end

    it "sets the stage name on acceptors when they are started" do
      stage = create_stage
      stage.add_acceptor MockAcceptor
      stage.add_acceptor MockAcceptor, :foo => :bar

      stage.start
      expect(MockAcceptor.stage_name).to eq(stage.name)
    end

    it "initially has an empty list of running acceptors" do
      stage = create_stage
      stage.add_acceptor MockAcceptor

      expect(stage.running_acceptors).not_to be_nil
      expect(stage.running_acceptors).to be_empty
    end

    it "keeps track of running acceptors" do
      stage = create_stage
      stage.add_acceptor MockAcceptor

      stage.start
      expect(stage.running_acceptors.size).to eq(1)
    end

    it "starts all acceptors" do
      stage = create_stage
      stage.add_acceptor MockAcceptor
      stage.add_acceptor MockAcceptor, :foo => :bar

      expect(MockAcceptor.start_count).to eq(0)

      stage.start
      sleep(0.05)

      expect(MockAcceptor.start_count).to eq(2)
    end

    it "adds a Batsir::Transformers::JSONInputTransformer to acceptors when no transformers are defined" do
      stage = create_stage
      stage.add_acceptor MockAcceptor

      stage.start

      expect(MockAcceptor.added_transformers.size).to eq(1)
      expect(MockAcceptor.added_transformers.first).to be_a Batsir::Transformers::JSONInputTransformer
    end

    it "adds defined transformers to the acceptors" do
      stage = create_stage
      stage.add_acceptor_transformer Batsir::Transformers::Transformer
      stage.add_acceptor MockAcceptor

      stage.start

      expect(MockAcceptor.added_transformers.size).to eq(1)
      expect(MockAcceptor.added_transformers.first).to be_a Batsir::Transformers::Transformer
    end
  end
end
