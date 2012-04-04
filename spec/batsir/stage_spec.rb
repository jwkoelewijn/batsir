require File.join( File.dirname(__FILE__), "..", "spec_helper" )

describe Batsir::Stage do
  def create_stage(options = {})
    defaults = {
      :chain        => Batsir::Chain.new(:persistence_operation => PersistenceOperation,
                                         :retrieval_operation => Batsir::RetrievalOperation),
      :queue        => :listening_queue,
      :notification_operation => Batsir::NotificationOperation,
      :object_type  => Object
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

  it "should be possible to set a queue for the stage" do
    queue = :queue
    stage = Batsir::Stage.new(:queue => queue)
    stage.queue.should == queue
  end

  it "should be possible to set the object type of the stage" do
    object_type = Object
    stage = Batsir::Stage.new(:object_type => object_type)
    stage.object_type.should == object_type
  end

  it "should not have a retrieval operation when no chain is configured and no stage specific retrieval operation is configured" do
    stage = Batsir::Stage.new
    stage.retrieval_operation.should be_nil
  end

  it "should not have a persistence operation when no chain is configured and no stage specific persistence operation is configured" do
    stage = Batsir::Stage.new
    stage.persistence_operation.should be_nil
  end

  it "should not have a notification operation when no chain is configured and no stage specific notification operation is configured" do
    stage = Batsir::Stage.new
    stage.notification_operation.should be_nil
  end

  it "should be possible to set a stage specific retrieval operation" do
    retrieval_operation = "Retrieval Operation"
    stage = Batsir::Stage.new(:retrieval_operation => retrieval_operation)
    stage.retrieval_operation.should == retrieval_operation
  end

  it "should be possible to set a stage specific persistence operation" do
    persistence_operation = "Persistence Operation"
    stage = Batsir::Stage.new(:persistence_operation => persistence_operation)
    stage.persistence_operation.should == persistence_operation
  end

  it "should be possible to set a stage specific notification operation" do
    notification_operation = "Notification Operation"
    stage = Batsir::Stage.new(:notification_operation => notification_operation)
    stage.notification_operation.should == notification_operation
  end

  it "should use the retrieval operation of the chain when no stage specific persistence operation is configured" do
    retrieval_operation = "Retrieval Operation"
    chain = Batsir::Chain.new(:retrieval_operation => retrieval_operation)
    stage = Batsir::Stage.new(:chain => chain)
    stage.retrieval_operation.should == retrieval_operation
  end

  it "should use the persistence operation of the chain when no stage specific persistence operation is configured" do
    persistence_operation = "Retrieval Operation"
    chain = Batsir::Chain.new(:persistence_operation => persistence_operation)
    stage = Batsir::Stage.new(:chain => chain)
    stage.persistence_operation.should == persistence_operation
  end

  it "should use the notification operation of the chain when no stage specific notification operation is configured" do
    notification_operation = "Notification Operation"
    chain = Batsir::Chain.new(:notification_operation => notification_operation)
    stage = Batsir::Stage.new(:chain => chain)
    stage.notification_operation.should == notification_operation
  end

  it "should create the object queue when the first operation is added to the stage" do
    operation = "Operation"
    stage = Batsir::Stage.new
    stage.add_operation(operation)
    stage.operation_queue.should_not be_nil
  end

  it "should add the operations to the object queue" do
    operation = "Operation"
    stage = Batsir::Stage.new
    stage.add_operation(operation)
    stage.operation_queue.should_not be_nil
    stage.operation_queue.should include operation
  end

  it "should add multiple operations to the same queue" do
    operation1 = "Operation 1"
    operation2 = "Operation 2"
    stage = Batsir::Stage.new
    stage.add_operation(operation1)
    op_queue = stage.operation_queue

    stage.add_operation(operation2)
    stage.operation_queue.should == op_queue
    stage.operation_queue.should include operation1
    stage.operation_queue.should include operation2
  end

  it "should initially have an empty notification queues" do
    stage = Batsir::Stage.new
    stage.notification_queues.should_not be_nil
    stage.notification_queues.should be_empty
  end

  it "should not be possible to set the notification queues" do
    stage = Batsir::Stage.new
    lambda { stage.notification_queues = {} }.should raise_error(NoMethodError)
  end

  it "should be possible to add a notification queue" do
    stage = Batsir::Stage.new

    parent_attribute = :parent_id
    notification_queue = :notification_queue

    stage.add_notification(notification_queue, parent_attribute)
    stage.notification_queues.should_not be_nil
    stage.notification_queues.should_not be_empty
    stage.notification_queues.should have_key notification_queue
    stage.notification_queues[notification_queue].should == parent_attribute
  end

  context "with respect to starting the stage" do
    module Bunny
      def self.instance
        @instance
      end

      def self.run
        @instance = BunnyInstance.new
        yield @instance
      end

      class BunnyInstance
        attr_accessor :queues
        def initialize
          @queues = {}
        end

        def exchange(exchange)
        end

        def queue(queue)
          @queues[queue] = BunnyQueue.new
        end
      end

      class BunnyQueue
        attr_accessor :block

        def subscribe(&block)
          @block = block
        end
      end
    end

    it "should create the stage configured queue when started" do
      stage = create_stage

      stage.start.should_not be_false
      instance = Bunny.instance
      instance.should_not be_nil
      instance.queues.size.should == 1
      instance.queues.keys.should include stage.queue
    end

    it "should dispatch a message to a stage actor when a message is received on the subscribed queue" do
      stage = create_stage

      stage.start.should_not be_false
      instance = Bunny.instance
      bunny_queue = instance.queues[stage.queue]
      bunny_queue.should_not be_nil
      block = bunny_queue.block
      block.should_not be_nil
    end
  end
end
