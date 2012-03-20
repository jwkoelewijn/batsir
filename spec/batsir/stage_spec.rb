require File.join( File.dirname(__FILE__), "..", "spec_helper" )

describe Batsir::Stage do
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

  context "With respect to building stages" do

    class Batsir::MockOperation < Batsir::Operation
      attr_accessor :execute_count
      def initialize
        @execute_count = 0
      end

      def execute(*args)
        @execute_count += 1
      end
    end

    class RetrievalOperation < Batsir::MockOperation
    end

    class PersistenceOperation < Batsir::MockOperation
    end

    class SumOperation < Batsir::MockOperation
    end

    class AverageOperation < Batsir::MockOperation
    end

    def create_stage(options = {})
      defaults = {
        :chain        => Batsir::Chain.new(:persistence_operation => PersistenceOperation,
                                           :retrieval_operation => RetrievalOperation),
        :queue        => :listening_queue,
        :object_type  => Object
      }
      Batsir::Stage.new(defaults.merge(options))
    end

    it "should not be possible to build a stage without a chain" do
      stage = create_stage(:chain => nil)
      stage.build.should be_false
      stage.should_not be_built
    end

    it "should not be possible to build a stage without a queue" do
      stage = create_stage(:queue => nil)
      stage.build.should be_false
      stage.should_not be_built
    end

    it "should not be possible to build a stage without an object type" do
      stage = create_stage(:object_type => nil)
      stage.build.should be_false
      stage.should_not be_built
    end

    it "should build correctly when a chain, a queue and an object_type are given" do
      stage = create_stage
      stage.build.should be_true
      stage.should be_built
    end

    it "should initially set the flag that the stage has been built to false" do
      stage = Batsir::Stage.new
      stage.should_not be_built
    end

    it "should set a flag that the stage has been built" do
      stage = create_stage
      stage.build.should be_true
      stage.should be_built
    end

    it "should initially not have an operation queue" do
      stage = Batsir::Stage.new
      stage.operation_queue.should be_nil
    end

    it "should create an operation queue during the stage build" do
      stage = create_stage
      stage.build.should be_true
      stage.operation_queue.should_not be_nil
    end

    it "should convert operation classes to instances during the build phase" do
      stage = create_stage
      stage.add_operation( SumOperation )
      stage.add_operation( AverageOperation )
      stage.operation_queue.each do |operation|
        operation.should be_a Class
      end

      stage.build.should be_true
      stage.operation_queue.each do |operation|
        operation.should_not be_a Class
      end
    end

    it "should return false if #execute is called while the stage has not been built" do
      stage = create_stage
      stage.execute.should be_false
    end

    it "should create notification operations for each notification queue" do
      notification_queue1 = :notification_queue1
      parent_attribute1   = :parent1

      stage = create_stage
      stage.notification_operation = Batsir::NotificationOperation
      stage.add_notification(notification_queue1, parent_attribute1)
      stage.build.should be_true
      operations = stage.operation_queue.notification_operations
      operations.size.should == 1
      operations.first.queue.should == notification_queue1
      operations.first.parent_attribute.should == parent_attribute1
    end

    it "should call execute on all operations in the operation queue when the #execute method is called" do
      stage = create_stage
      stage.add_operation( SumOperation )
      stage.add_operation( AverageOperation )
      stage.build.should be_true
      stage.operation_queue.each do |operation|
        operation.execute_count.should == 0
      end
      stage.execute
      stage.operation_queue.each do |operation|
        operation.execute_count.should == 1
      end
    end

    it "should create an amqp queue with the configured name on which it will listen for messages" do

    end

    it "should call the #execute method of the stage when a message is received" do

    end

  end
end
