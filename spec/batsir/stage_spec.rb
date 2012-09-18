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
    Batsir::Stage.ancestors.should include Celluloid
  end

  it "can name the stage" do
    stage = Batsir::Stage.new
    name = "StageName"
    stage.name = name
    stage.name.should == name
  end

  it "can set the name in the constructor" do
    name = "StageName"
    stage = Batsir::Stage.new(:name => name)
    stage.name.should == name
  end

  it "can set the aggregator chain to which the stage belongs" do
    chain = "Chain"
    stage = Batsir::Stage.new(:chain => chain)
    stage.chain.should == chain
  end

  context "with respect to filters" do
    it "cannot set the filters directly" do
      stage = Batsir::Stage.new
      lambda { stage.filters = {} }.should raise_error(NoMethodError)
    end

    it "stores filters using filter declarations" do
      filter = "Filter"
      stage = Batsir::Stage.new
      stage.add_filter(filter)
      stage.filter_declarations.should_not be_nil
      stage.filter_declarations.size.should == 1
      declaration = stage.filter_declarations.first
      declaration.filter.should == filter
      declaration.options.should == {}
    end

    it "returns an empty array when the #filters method is called without any declared filters" do
      stage = Batsir::Stage.new
      stage.filters.should_not be_nil
      stage.filters.should == []
    end

    it "returns all filters when the #filters method is called" do
      filter1 = "Filter"
      filter2 = "Filter2"
      filter3 = "Filter"
      stage = Batsir::Stage.new
      stage.add_filter(filter1)
      stage.add_filter(filter2)
      stage.add_filter(filter3)

      stage.filters.should_not be_nil
      stage.filters.size.should == 3
      stage.filters[0].should == filter1
      stage.filters[1].should == filter2
      stage.filters[2].should == filter3
    end

    it "adds a filter to its filters" do
      filter = "Filter"
      stage = Batsir::Stage.new
      stage.add_filter(filter)
      stage.filters.should_not be_nil
      stage.filters.should include filter
    end

    it "can have multiple filters of the same class but with different options" do
      stage = Batsir::Stage.new
      stage.add_filter(:filter)
      stage.add_filter(:filter, :foo => :bar)

      stage.filters.should include :filter
      stage.filters.size.should == 2
    end

    it "can add filters with on options hash" do
      filter = :filter
      options = {:foo => :bar}

      stage = Batsir::Stage.new
      stage.add_filter(filter, options)

      stage.filters.should_not be_nil
      stage.filters.should_not be_empty
      stage.filters.should include filter
      stage.filter_declarations.first.options.should == options
    end

    it "can add multiple filters with option hashes" do
      filter1 = :filter1
      filter2 = :filter2
      options1 = {:foo1 => :bar1}
      options2 = {:foo2 => :bar2}

      stage = Batsir::Stage.new
      stage.add_filter(filter1, options1)
      stage.add_filter(filter2, options2)

      stage.filters.should include filter1
      stage.filters.should include filter2
      stage.filter_declarations[0].options.should == options1
      stage.filter_declarations[1].options.should == options2
    end

    it "adds empty options hashes to filters when no option hash is given" do
      filter = :filter

      stage = Batsir::Stage.new
      stage.add_filter(filter)

      stage.filters.should_not be_nil
      stage.filters.should_not be_empty
      stage.filters.should include filter
      stage.filter_declarations.first.options.should == {}
    end

    it "can add a filter more than once" do
      filter = :filter
      stage = Batsir::Stage.new
      stage.add_filter(filter)
      stage.add_filter(filter)
      stage.filters.should_not be_nil
      stage.filters.should_not be_empty
      stage.filters.size.should == 2
    end

    it "can add filter with different options and respect the order" do
      filter = :filter
      other_filter = :other_filter

      stage = Batsir::Stage.new
      stage.add_filter(filter)
      stage.add_filter(other_filter)
      stage.add_filter(filter, :foo => :bar)
      stage.filters.size.should == 3
    end
  end

  context "with respect to acceptors" do
    it "initially has an empty list of acceptors" do
      stage = Batsir::Stage.new
      stage.acceptors.should_not be_nil
      stage.acceptors.should be_empty
    end

    it "cannot set the acceptors directly" do
      stage = Batsir::Stage.new
      lambda { stage.acceptors = {} }.should raise_error(NoMethodError)
    end

    it "can add new acceptors" do
      stage = Batsir::Stage.new
      stage.add_acceptor(:acceptor)
      stage.acceptors.should_not be_nil
      stage.acceptors.should_not be_empty
      stage.acceptors.keys.should include :acceptor
    end

    it "stores a set of different options for each acceptor" do
      stage = Batsir::Stage.new
      stage.add_acceptor(:acceptor)
      stage.acceptors[:acceptor].should be_a Set
    end

    it "can have multiple acceptors of the same class but with different options" do
      stage = Batsir::Stage.new
      stage.add_acceptor(:acceptor_class)
      stage.add_acceptor(:acceptor_class, :foo => :bar)

      stage.acceptors.should_not be_nil
      stage.acceptors.should_not be_empty
      stage.acceptors.keys.should include :acceptor_class
      stage.acceptors[:acceptor_class].size.should == 2
    end

    it "can add an acceptor with an options hash" do
      stage = Batsir::Stage.new
      options = {:foo => :bar}
      stage.add_acceptor(:acceptor, options)

      stage.acceptors.should_not be_nil
      stage.acceptors.should_not be_empty
      stage.acceptors.keys.should include :acceptor
      stage.acceptors[:acceptor].first.should == options
    end

    it "adds an empty options hash for added acceptors without options" do
      stage = Batsir::Stage.new
      stage.add_acceptor(:acceptor)

      stage.acceptors.should_not be_nil
      stage.acceptors.should_not be_empty
      stage.acceptors.keys.should include :acceptor
      stage.acceptors[:acceptor].first.should == {}
    end

    it "initially has an empty list of cancellators" do
      stage = Batsir::Stage.new
      stage.cancellators.should_not be_nil
      stage.cancellators.should be_empty
    end

    context "with respect to acceptor transformers" do
      it "has an empty acceptor transformers queue by default" do
        stage = Batsir::Stage.new

        stage.acceptor_transformers.should_not be_nil
        stage.acceptor_transformers.should be_empty
      end

      it "can add a transformer to the acceptors" do
        stage = Batsir::Stage.new

        transformer = :transformer

        stage.add_acceptor_transformer(transformer)
        stage.acceptor_transformers.should_not be_empty

        stage.acceptor_transformers.first.transformer.should == transformer
      end

      it "adds an empty options hash by default" do
        stage = Batsir::Stage.new

        transformer = :transformer
        stage.add_acceptor_transformer(transformer)
        stage.acceptor_transformers.should_not be_empty

        stage.acceptor_transformers.first.options.should == {}
      end

      it "can add options to a transformer" do
        stage = Batsir::Stage.new

        transformer = :transformer
        options = {:foo => :bar}

        stage.add_acceptor_transformer(transformer, options)
        stage.acceptor_transformers.should_not be_empty

        stage.acceptor_transformers.first.transformer.should == transformer
        stage.acceptor_transformers.first.options.should == options
      end

      it "can add multiple transformers" do
        stage = Batsir::Stage.new

        transformer1 = :transformer1
        transformer2 = :transformer2

        stage.add_acceptor_transformer(transformer1)
        stage.add_acceptor_transformer(transformer2)
        stage.acceptor_transformers.should_not be_empty
        stage.acceptor_transformers.size.should == 2

        transformers = stage.acceptor_transformers.map{|td| td.transformer}
        transformers.should include transformer1
        transformers.should include transformer2
      end

      it "keeps the transformers in the order of declaration" do
        stage = Batsir::Stage.new

        transformer1 = :transformer1
        transformer2 = :transformer2

        stage.add_acceptor_transformer(transformer1)
        stage.add_acceptor_transformer(transformer2)
        stage.acceptor_transformers.should_not be_empty
        stage.acceptor_transformers.size.should == 2

        stage.acceptor_transformers.first.transformer.should == transformer1
        stage.acceptor_transformers.last.transformer.should == transformer2
      end

      it "can add a transformer more than once" do
        stage = Batsir::Stage.new

        transformer = :transformer

        stage.add_acceptor_transformer(transformer)
        stage.add_acceptor_transformer(transformer)
        stage.acceptor_transformers.should_not be_empty
        stage.acceptor_transformers.size.should == 2

        stage.acceptor_transformers.first.transformer.should == transformer
        stage.acceptor_transformers.last.transformer.should == transformer
      end
    end

  end

  context "with respect to notifiers" do
    it "initially has an empty notifiers queue" do
      stage = Batsir::Stage.new
      stage.notifiers.should_not be_nil
      stage.notifiers.should be_empty
    end

    it "cannot set the notifiers directly" do
      stage = Batsir::Stage.new
      lambda { stage.notifiers = {} }.should raise_error(NoMethodError)
    end

    it "can add new notifiers" do
      stage = Batsir::Stage.new

      stage.add_notifier(:notifier)
      stage.notifiers.should_not be_nil
      stage.notifiers.should_not be_empty
      stage.notifiers.keys.should include :notifier
    end

    it "stores a set of different options for each notifier" do
      stage = Batsir::Stage.new
      stage.add_notifier(:notifier)
      stage.notifiers[:notifier].should be_a Set
    end

    it "can have multiple notifiers of the same class but with different options" do
      stage = Batsir::Stage.new
      stage.add_notifier(:notifier_class)
      stage.add_notifier(:notifier_class, :foo => :bar)

      stage.notifiers.should_not be_nil
      stage.notifiers.keys.should include :notifier_class
      stage.notifiers[:notifier_class].size.should == 2
    end

    it "can set a notifier with an options hash" do
      stage = Batsir::Stage.new

      options = {:foo => :bar}

      stage.add_notifier(:notifier, options)
      stage.notifiers.should_not be_nil
      stage.notifiers.should_not be_empty
      stage.notifiers.keys.should include :notifier
      stage.notifiers[:notifier].first.should == options
    end

    it "adds an empty options hash for added notifiers without options" do
      stage = Batsir::Stage.new

      stage.add_notifier(:notifier)
      stage.notifiers.should_not be_nil
      stage.notifiers.should_not be_empty
      stage.notifiers.keys.should include :notifier
      stage.notifiers[:notifier].first.should == {}
    end

    context "with respect to notifier transformers" do
      it "has an empty notifier transformers queue by default" do
        stage = Batsir::Stage.new

        stage.notifier_transformers.should_not be_nil
        stage.notifier_transformers.should be_empty
      end

      it "can add a transformer to the notifiers" do
        stage = Batsir::Stage.new

        transformer = :transformer

        stage.add_notifier_transformer(transformer)
        stage.notifier_transformers.should_not be_empty

        stage.notifier_transformers.first.transformer.should == transformer
      end

      it "adds an empty options hash by default" do
        stage = Batsir::Stage.new

        transformer = :transformer
        stage.add_notifier_transformer(transformer)
        stage.notifier_transformers.should_not be_empty

        stage.notifier_transformers.first.options.should == {}
      end

      it "can add options to a transformer" do
        stage = Batsir::Stage.new

        transformer = :transformer
        options = {:foo => :bar}

        stage.add_notifier_transformer(transformer, options)
        stage.notifier_transformers.should_not be_empty

        stage.notifier_transformers.first.transformer.should == transformer
        stage.notifier_transformers.first.options.should == options
      end

      it "can add multiple transformers" do
        stage = Batsir::Stage.new

        transformer1 = :transformer1
        transformer2 = :transformer2

        stage.add_notifier_transformer(transformer1)
        stage.add_notifier_transformer(transformer2)
        stage.notifier_transformers.should_not be_empty
        stage.notifier_transformers.size.should == 2

        transformers = stage.notifier_transformers.map{|td| td.transformer}
        transformers.should include transformer1
        transformers.should include transformer2
      end

      it "keeps the transformers in the order of declaration" do
        stage = Batsir::Stage.new

        transformer1 = :transformer1
        transformer2 = :transformer2

        stage.add_notifier_transformer(transformer1)
        stage.add_notifier_transformer(transformer2)
        stage.notifier_transformers.should_not be_empty
        stage.notifier_transformers.size.should == 2

        stage.notifier_transformers.first.transformer.should == transformer1
        stage.notifier_transformers.last.transformer.should == transformer2
      end

      it "can add a transformer more than once" do
        stage = Batsir::Stage.new

        transformer = :transformer

        stage.add_notifier_transformer(transformer)
        stage.add_notifier_transformer(transformer)
        stage.notifier_transformers.should_not be_empty
        stage.notifier_transformers.size.should == 2

        stage.notifier_transformers.first.transformer.should == transformer
        stage.notifier_transformers.last.transformer.should == transformer
      end
    end
  end

  context "with respect to compiling the stage" do
    before :all do
      @stage_name = "Stage 1"

      stage = Batsir::Stage.new(:name => @stage_name)

      stage.add_notifier_transformer(Batsir::Transformers::Transformer)
      stage.add_notifier(Batsir::Notifiers::Notifier)
      stage.add_filter(Batsir::Filter)
      stage.add_filter(Batsir::Filter)

      @created_class = eval( stage.compile )
    end

    it "creates a class named after the stage name" do
      @created_class.to_s.should == "Stage1Worker"
    end

    it "creates a Batsir::StageWorker class" do
      @created_class.ancestors.should include Batsir::StageWorker
    end

    it "creates a class that includes Sidekiq::Worker" do
      @created_class.ancestors.should include Sidekiq::Worker
    end

    it "creates a worker class named after the stage name" do
      @created_class.stage_name.should == @stage_name
    end

    it "adds the notifier during compilation" do
      instance = @created_class.new
      instance.filter_queue.notifiers.should_not be_nil
      instance.filter_queue.notifiers.should_not be_empty
      instance.filter_queue.notifiers.size.should == 1
      instance.filter_queue.notifiers.first.should be_a Batsir::Notifiers::Notifier
    end

    it "adds a transformer to the notifier during compilation" do
      instance = @created_class.new

      instance.filter_queue.notifiers.first.transformer_queue.should_not be_empty
      instance.filter_queue.notifiers.first.transformer_queue.first.should be_a Batsir::Transformers::Transformer
    end

    it "adds a JSONOutputTransformer by default when no transformers are defined" do
      stage = Batsir::Stage.new(:name => "SomeName")

      stage.add_notifier(Batsir::Notifiers::Notifier)

      created_class = eval( stage.compile )
      instance = created_class.new

      instance.filter_queue.notifiers.should_not be_nil
      instance.filter_queue.notifiers.should_not be_empty
      instance.filter_queue.notifiers.first.transformer_queue.should_not be_empty
      instance.filter_queue.notifiers.first.transformer_queue.first.should be_a Batsir::Transformers::JSONOutputTransformer
    end

    it "initialises a class local filter queue" do
      @created_class.filter_queue.should_not be_nil
      @created_class.filter_queue.should_not be_empty
    end

    it "has intitialized the filters" do
      @created_class.filter_queue.map{|filter| filter.class.to_s}.should include "Batsir::Filter"
    end

    it "can add a filter multiple times" do
      @created_class.filter_queue.select{ |filter| filter.class == Batsir::Filter }.size.should == 2
    end

    it "uses the class local filter queue once an instance is initialized" do
      instance = @created_class.new
      instance.filter_queue.should == @created_class.filter_queue
    end

    it "initialises all filters in the filter queue" do
      @created_class.filter_queue.each do |filter|
        filter.should_not be_a Class
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
      MockAcceptor.stage_name.should == stage.name
    end

    it "initially has an empty list of running acceptors" do
      stage = create_stage
      stage.add_acceptor MockAcceptor

      stage.running_acceptors.should_not be_nil
      stage.running_acceptors.should be_empty
    end

    it "keeps track of running acceptors" do
      stage = create_stage
      stage.add_acceptor MockAcceptor

      stage.start
      stage.running_acceptors.size.should == 1
    end

    it "adds a cancellator to each acceptor" do
      stage = create_stage
      stage.add_acceptor MockAcceptor

      stage.start
      stage.running_acceptors.first.cancellator.should_not be_nil
    end

    it "adds cancellators to the stage list of cancellators" do
      stage = create_stage
      stage.add_acceptor MockAcceptor
      stage.add_acceptor MockAcceptor, :foo => :bar

      stage.start
      stage.cancellators.size.should == 2
    end

    it "starts all acceptors" do
      stage = create_stage
      stage.add_acceptor MockAcceptor
      stage.add_acceptor MockAcceptor, :foo => :bar

      MockAcceptor.start_count.should == 0

      stage.start
      sleep(0.05)

      MockAcceptor.start_count.should == 2
    end

    it "adds a Batsir::Transformers::JSONInputTransformer to acceptors when no transformers are defined" do
      stage = create_stage
      stage.add_acceptor MockAcceptor

      stage.start

      MockAcceptor.added_transformers.size.should == 1
      MockAcceptor.added_transformers.first.should be_a Batsir::Transformers::JSONInputTransformer
    end

    it "adds defined transformers to the acceptors" do
      stage = create_stage
      stage.add_acceptor_transformer Batsir::Transformers::Transformer
      stage.add_acceptor MockAcceptor

      stage.start

      MockAcceptor.added_transformers.size.should == 1
      MockAcceptor.added_transformers.first.should be_a Batsir::Transformers::Transformer
    end
  end
end
