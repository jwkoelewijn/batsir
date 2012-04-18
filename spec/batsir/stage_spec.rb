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

  it "should be possible to name the stage" do
    stage = Batsir::Stage.new
    name = "StageName"
    stage.name = name
    stage.name.should == name
  end

  it "should be possible to set the name in the constructor" do
    name = "StageName"
    stage = Batsir::Stage.new(:name => name)
    stage.name.should == name
  end

  it "should be possible to set the aggregator chain to which the stage belongs" do
    chain = "Chain"
    stage = Batsir::Stage.new(:chain => chain)
    stage.chain.should == chain
  end

  it "should not be possible to set the filters" do
    stage = Batsir::Stage.new
    lambda { stage.filters = {} }.should raise_error(NoMethodError)
  end

  it "should add a filter to its filters" do
    filter = "Filter"
    stage = Batsir::Stage.new
    stage.add_filter(filter)
    stage.filters.should_not be_nil
    stage.filters.keys.should include filter
  end

  it "should store an ordered set of different options for each filter" do
    stage = Batsir::Stage.new
    stage.add_filter(:filter)
    stage.filters[:filter].should be_a SortedSet
  end

  it "should be possible to have multiple filters of the same class but with different options" do
    stage = Batsir::Stage.new
    stage.add_filter(:filter)
    stage.add_filter(:filter, :foo => :bar)

    stage.filters.keys.should include :filter
    stage.filters[:filter].size.should == 2
  end

  it "should add multiple filters to the same queue" do
    filter1 = "Filter 1"
    filter2 = "Filter 2"
    stage = Batsir::Stage.new
    stage.add_filter(filter1)
    filters = stage.filters

    stage.add_filter(filter2)
    stage.filters.should == filters
    stage.filters.keys.should include filter1
    stage.filters.keys.should include filter2
  end

  it "should be possible to add filters with on options hash" do
    filter = :filter
    options = {:foo => :bar}

    stage = Batsir::Stage.new
    stage.add_filter(filter, options)

    stage.filters.should_not be_nil
    stage.filters.should_not be_empty
    stage.filters.keys.should include filter
    stage.filters[filter].first.should == options
  end

  it "should be possible to add multiple filters with option hashes" do
    filter1 = :filter1
    filter2 = :filter2
    options1 = {:foo1 => :bar1}
    options2 = {:foo2 => :bar2}

    stage = Batsir::Stage.new
    stage.add_filter(filter1, options1)
    stage.add_filter(filter2, options2)

    stage.filters.keys.should include filter1
    stage.filters.keys.should include filter2
    stage.filters[filter1].first.should == options1
    stage.filters[filter2].first.should == options2
  end

  it "should add empty options hashes to filters when no option hash is given" do
    filter = :filter

    stage = Batsir::Stage.new
    stage.add_filter(filter)

    stage.filters.should_not be_nil
    stage.filters.should_not be_empty
    stage.filters.keys.should include filter
    stage.filters[filter].first.should == {}
  end

  it "should initially have an empty list of acceptors" do
    stage = Batsir::Stage.new
    stage.acceptors.should_not be_nil
    stage.acceptors.should be_empty
  end

  it "should not be possible to set the acceptors" do
    stage = Batsir::Stage.new
    lambda { stage.acceptors = {} }.should raise_error(NoMethodError)
  end

  it "should be possible to add new acceptors" do
    stage = Batsir::Stage.new
    stage.add_acceptor(:acceptor)
    stage.acceptors.should_not be_nil
    stage.acceptors.should_not be_empty
    stage.acceptors.keys.should include :acceptor
  end

  it "should store a set of different options for each acceptor" do
    stage = Batsir::Stage.new
    stage.add_acceptor(:acceptor)
    stage.acceptors[:acceptor].should be_a Set
  end

  it "should be possible to have multiple acceptors of the same class but with different options" do
    stage = Batsir::Stage.new
    stage.add_acceptor(:acceptor_class)
    stage.add_acceptor(:acceptor_class, :foo => :bar)

    stage.acceptors.should_not be_nil
    stage.acceptors.should_not be_empty
    stage.acceptors.keys.should include :acceptor_class
    stage.acceptors[:acceptor_class].size.should == 2
  end

  it "should be possible to add an acceptor with an options hash" do
    stage = Batsir::Stage.new
    options = {:foo => :bar}
    stage.add_acceptor(:acceptor, options)

    stage.acceptors.should_not be_nil
    stage.acceptors.should_not be_empty
    stage.acceptors.keys.should include :acceptor
    stage.acceptors[:acceptor].first.should == options
  end

  it "should add an empty options hash for added acceptors without options" do
    stage = Batsir::Stage.new
    stage.add_acceptor(:acceptor)

    stage.acceptors.should_not be_nil
    stage.acceptors.should_not be_empty
    stage.acceptors.keys.should include :acceptor
    stage.acceptors[:acceptor].first.should == {}
  end

  it "should initially have an empty notifiers queue" do
    stage = Batsir::Stage.new
    stage.notifiers.should_not be_nil
    stage.notifiers.should be_empty
  end

  it "should not be possible to set the notifiers" do
    stage = Batsir::Stage.new
    lambda { stage.notifiers = {} }.should raise_error(NoMethodError)
  end

  it "should be possible to add new notifiers" do
    stage = Batsir::Stage.new

    stage.add_notifier(:notifier)
    stage.notifiers.should_not be_nil
    stage.notifiers.should_not be_empty
    stage.notifiers.keys.should include :notifier
  end

  it "should store a set of different options for each notifier" do
    stage = Batsir::Stage.new
    stage.add_notifier(:notifier)
    stage.notifiers[:notifier].should be_a Set
  end

  it "should be possible to have multiple notifiers of the same class but with different options" do
    stage = Batsir::Stage.new
    stage.add_notifier(:notifier_class)
    stage.add_notifier(:notifier_class, :foo => :bar)

    stage.notifiers.should_not be_nil
    stage.notifiers.keys.should include :notifier_class
    stage.notifiers[:notifier_class].size.should == 2
  end

  it "should be possible to set a notifier with an options hash" do
    stage = Batsir::Stage.new

    options = {:foo => :bar}

    stage.add_notifier(:notifier, options)
    stage.notifiers.should_not be_nil
    stage.notifiers.should_not be_empty
    stage.notifiers.keys.should include :notifier
    stage.notifiers[:notifier].first.should == options
  end

  it "should add an empty options hash for added notifiers without options" do
    stage = Batsir::Stage.new

    stage.add_notifier(:notifier)
    stage.notifiers.should_not be_nil
    stage.notifiers.should_not be_empty
    stage.notifiers.keys.should include :notifier
    stage.notifiers[:notifier].first.should == {}
  end

  context "with respect to compiling the stage" do
    before :all do
      @stage_name = "Stage 1"

      stage = Batsir::Stage.new(:name => @stage_name)

      parent_attribute = :parent_id
      notification_queue = :notification_queue

      stage.add_notifier(Batsir::Notifiers::Notifier)
      stage.add_filter(Batsir::Filter)

      @created_class = eval( stage.compile )
    end

    it "should create a class named after the stage name" do
      @created_class.to_s.should == "Stage1Worker"
    end

    it "should create a Batsir::StageWorker class" do
      @created_class.ancestors.should include Batsir::StageWorker
    end

    it "should create a class that includes Sidekiq::Worker" do
      @created_class.ancestors.should include Sidekiq::Worker
    end

    it "should create a worker class named after the stage name" do
      @created_class.stage_name.should == @stage_name
    end

    it "should initialize a class local filter queue" do
      @created_class.filter_queue.should_not be_nil
      @created_class.filter_queue.should_not be_empty
    end

    it "should have intitialized the filters" do
      @created_class.filter_queue.map{|filter| filter.class.to_s}.should include "Batsir::Filter"
    end

    it "should use the class local filter queue once an instance is initialized" do
      instance = @created_class.new
      instance.filter_queue.should == @created_class.filter_queue
    end

    it "should initialize all filters in the filter queue" do
      @created_class.filter_queue.each do |filter|
        filter.should_not be_a Class
      end
    end
  end

  context "with respect to starting the stage" do
    before :all do
      class MockAcceptor < Batsir::Acceptors::Acceptor
        def start!
          start
        end

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

        def self.start_count
          @@start_count ||= 0
        end

        def self.reset
          @@start_count = 0
          @@stage_name = nil
        end
      end
    end

    before :each do
      MockAcceptor.reset
    end

    it "should set the stage name on acceptors when they are started" do
      stage = create_stage
      stage.add_acceptor MockAcceptor
      stage.add_acceptor MockAcceptor, :foo => :bar

      stage.start
      MockAcceptor.stage_name.should == stage.name
    end


    it "should start all acceptors" do
      stage = create_stage
      stage.add_acceptor MockAcceptor
      stage.add_acceptor MockAcceptor, :foo => :bar

      MockAcceptor.start_count.should == 0

      stage.start

      MockAcceptor.start_count.should == 2
    end
  end
end
