require File.join( File.dirname(__FILE__), "..", "spec_helper" )

describe Batsir::Stage do
  def create_stage(options = {})
    defaults = {
      :chain        => Batsir::Chain.new
    }
    Batsir::Stage.new(defaults.merge(options))
  end

  before :all do
    class StubOperation < Batsir::Operation
    end

    class AnotherOperation < Batsir::Operation
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

  it "should create the object queue when the first operation is added to the stage" do
    operation = "Operation"
    stage = Batsir::Stage.new
    stage.add_filter(operation)
    stage.filter_queue.should_not be_nil
  end

  it "should add the operations to the object queue" do
    operation = "Operation"
    stage = Batsir::Stage.new
    stage.add_filter(operation)
    stage.filter_queue.should_not be_nil
    stage.filter_queue.should include operation
  end

  it "should add multiple operations to the same queue" do
    operation1 = "Operation 1"
    operation2 = "Operation 2"
    stage = Batsir::Stage.new
    stage.add_filter(operation1)
    filter_queue = stage.filter_queue

    stage.add_filter(operation2)
    stage.filter_queue.should == filter_queue
    stage.filter_queue.should include operation1
    stage.filter_queue.should include operation2
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

  it "should be possible to add an acceptor with an options hash" do
    stage = Batsir::Stage.new
    options = {:foo => :bar}
    stage.add_acceptor(:acceptor, options)

    stage.acceptors.should_not be_nil
    stage.acceptors.should_not be_empty
    stage.acceptors.keys.should include :acceptor
    stage.acceptors[:acceptor].should == options
  end

  it "should add an empty options hash for added acceptors without options" do
    stage = Batsir::Stage.new
    stage.add_acceptor(:acceptor)

    stage.acceptors.should_not be_nil
    stage.acceptors.should_not be_empty
    stage.acceptors.keys.should include :acceptor
    stage.acceptors[:acceptor].should == {}
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

  it "should be possible to set a notifier with an options hash" do
    stage = Batsir::Stage.new

    options = {:foo => :bar}

    stage.add_notifier(:notifier, options)
    stage.notifiers.should_not be_nil
    stage.notifiers.should_not be_empty
    stage.notifiers.keys.should include :notifier
    stage.notifiers[:notifier].should == options
  end

  it "should add an empty options hash for added notifiers without options" do
    stage = Batsir::Stage.new

    stage.add_notifier(:notifier)
    stage.notifiers.should_not be_nil
    stage.notifiers.should_not be_empty
    stage.notifiers.keys.should include :notifier
    stage.notifiers[:notifier].should == {}
  end

  context "with respect to compiling the stage" do
    before :all do
      @stage_name = "Stage 1"

      stage = Batsir::Stage.new(:name => @stage_name)

      parent_attribute = :parent_id
      notification_queue = :notification_queue

      stage.add_notifier(Batsir::NotificationOperation)
      stage.add_filter(Batsir::Operation)

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

#  context "with respect to starting the stage" do
#    module Bunny
#      def self.instance
#        @instance
#      end
#
#      def self.run
#        @instance = BunnyInstance.new
#        yield @instance
#      end
#
#      class BunnyInstance
#        attr_accessor :queues
#        def initialize
#          @queues = {}
#        end
#
#        def exchange(exchange)
#        end
#
#        def queue(queue)
#          @queues[queue] = BunnyQueue.new
#        end
#      end
#
#      class BunnyQueue
#        attr_accessor :block
#
#        def subscribe(&block)
#          @block = block
#        end
#      end
#    end
#
#    it "should create the stage configured queue when started" do
#      stage = create_stage
#
#      stage.start.should_not be_false
#      instance = Bunny.instance
#      instance.should_not be_nil
#      instance.queues.size.should == 1
#      instance.queues.keys.should include stage.queue
#    end
#
#    it "should dispatch a message to a stage actor when a message is received on the subscribed queue" do
#      stage = create_stage
#
#      stage.start.should_not be_false
#      instance = Bunny.instance
#      bunny_queue = instance.queues[stage.queue]
#      bunny_queue.should_not be_nil
#      block = bunny_queue.block
#      block.should_not be_nil
#    end
#  end
end
