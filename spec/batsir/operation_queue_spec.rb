require File.join( File.dirname(__FILE__), "..", "spec_helper" )

describe Batsir::OperationQueue do
  it "should be possible to add an operation to a queue" do
    queue = Batsir::OperationQueue.new
    queue.add("Operation")
    queue.should include "Operation"
  end

  it "should be possible to set a persist operation" do
    queue = Batsir::OperationQueue.new
    operation = "FakePersistOperation"
    queue.persist_operation = operation
    queue.persist_operation.should == operation
  end

  it "should place persist operations to the back of the queue" do
    queue = Batsir::OperationQueue.new
    operation = "FakePersistOperation"
    queue.persist_operation = operation

    queue.add("AnotherOperation")
    ops = []
    queue.each do |op|
      ops << op
    end
    ops.last.should == operation
  end

  it "should not return nil as last operation when no persist operation is added" do
    queue = Batsir::OperationQueue.new

    queue.add("AnotherOperation")
    ops = []
    queue.each do |op|
      ops << op
    end
    ops.last.should_not be_nil
  end

  it "should be possible to add a notification operation" do
    queue = Batsir::OperationQueue.new
    notification_operation = "NotificationOperation"
    queue.add_notification_operation(notification_operation)
    queue.should include notification_operation
  end

  it "should be possible to add multiple notification operations" do
    queue = Batsir::OperationQueue.new
    ops = []
    3.times do |index|
      ops << "Operation #{index}"
      queue.add_notification_operation("Operation #{index}")
    end

    ops.each {|op| queue.should include op}
  end

  it "should return notification operations as the last operations" do
    queue = Batsir::OperationQueue.new
    operation = "NotificationOperation"

    queue.add("SomeOperation")
    queue.add_notification_operation(operation)
    queue.add("AnotherOperation")

    ops = []
    queue.each do |op|
      ops << op
    end
    ops.last.should == operation
  end

  it "should only be possible to add RetrievalOperations as retrieval operations" do
    queue = Batsir::OperationQueue.new
    wrong_operation = "String Retrieval Operation"

    queue.retrieval_operation = wrong_operation
    queue.retrieval_operation.should be_nil

    operation = Batsir::RetrievalOperation
    queue.retrieval_operation = operation
    queue.retrieval_operation.should == operation

    operation_instance = operation.new
    queue.retrieval_operation = operation_instance
    queue.retrieval_operation.should == operation_instance
  end

  it "should place the retrieval operation in front of all other operations" do
    queue = Batsir::OperationQueue.new
    operation = "NotificationOperation"

    queue.add("SomeOperation")
    queue.add_notification_operation(operation)
    queue.add("AnotherOperation")

    queue.persist_operation = "SomePersistOperation"
    retrieval_operation = Batsir::RetrievalOperation
    queue.retrieval_operation = retrieval_operation

    queue.first.should == retrieval_operation
  end

  it "should place the persist operation in front of notification operations" do
    queue = Batsir::OperationQueue.new
    operation = "NotificationOperation"

    queue.add("SomeOperation")
    queue.add_notification_operation(operation)
    queue.add("AnotherOperation")

    queue.persist_operation = "SomePersistOperation"

    ops = []
    queue.each do |op|
      ops << op
    end

    ops.index("SomePersistOperation").should < ops.index(operation)
  end

  it "should respond true to #empty? when no operations are added" do
    queue = Batsir::OperationQueue.new
    queue.should be_empty
  end

  it "should not be empty when a notification operation is added" do
    queue = Batsir::OperationQueue.new
    operation = "NotificationOperation"

    queue.add_notification_operation(operation)

    queue.should_not be_empty
  end

  it "should not be empty when a persist operation is added" do
    queue = Batsir::OperationQueue.new
    queue.persist_operation = "SomePersistOperation"

    queue.should_not be_empty
  end

  it "should not be empty when a regular operation is added" do
    queue = Batsir::OperationQueue.new

    queue.add("SomeOperation")
    queue.should_not be_empty
  end

  context "with respect to instantiating operation queues" do

    before :each do
      chain_options = {
        :retrieval_operation => Batsir::RetrievalOperation,
        :persistence_operation => PersistenceOperation
      }

      @chain = Batsir::Chain.new(chain_options)

      stage_options = {
        :queue => :listening_queue,
        :notification_operation => Batsir::NotificationOperation,
        :chain => @chain,
        :object_type => Object
      }
      @stage = Batsir::Stage.new(stage_options)

      @stage.add_operation SumOperation
      @stage.add_operation AverageOperation
      @stage.add_notification( :notification_queue_1, :parent_id_1 )
      @stage.add_notification( :notification_queue_2, :parent_id_2 )
      @stage.build.should be_true
      operation_queue = @stage.operation_queue
      @instantiated_queue = operation_queue.instantiate_for(@stage)
    end

    it "should initially create non-instantiated operation queues" do
      queue = Batsir::OperationQueue.new
      queue.should_not be_instantiated
    end

    it "should be possible to set the instantiated property of an operation queue" do
      queue = Batsir::OperationQueue.new
      queue.instantiated = true
      queue.should be_instantiated
    end

    it "should create a new operation queue when being instantiated" do
      @instantiated_queue.should_not == @stage.operation_queue
    end

    it "should return an operation queue that is instantiated" do
      @instantiated_queue.should be_instantiated
    end

    it "should add the persist operation of the stage when being instantiated" do
      @instantiated_queue.persist_operation.should_not be_nil
    end

    it "should instantiate a persist operation of the type being configured in the stage" do
      @instantiated_queue.persist_operation.should be_a @stage.persistence_operation
    end

    it "should add the retrieval operation of the stage when being instantiated" do
      @instantiated_queue.retrieval_operation.should_not be_nil
    end

    it "should instantiate a retrieval operation of the type being configured in the stage" do
      @instantiated_queue.retrieval_operation.should be_a @stage.retrieval_operation
    end

    it "should create notification operations of the stage configured type for all notifications in the stage" do
      @instantiated_queue.notification_operations.size.should == 2
      @instantiated_queue.notification_operations.each do | operation |
        operation.should be_a @stage.notification_operation
      end
    end

    it "should initialize the notification operations of with the correct queue and parent attributes" do
      @instantiated_queue.notification_operations.each do | operation |
        operation.queue.should_not be_nil
        operation.parent_attribute.should_not be_nil
      end

      operations = @instantiated_queue.notification_operations
      notification1s = operations.select{ |op| op.queue == :notification_queue_1 }
      notification1s.size.should == 1
      notification1s.first.parent_attribute.should == :parent_id_1

      notification2s = operations.select{ |op| op.queue == :notification_queue_2 }
      notification2s.size.should == 1
      notification2s.first.parent_attribute.should == :parent_id_2
    end

    it "should instantiate all regular operations" do
      @instantiated_queue.operations.each do |operation|
        operation.should_not be_a Class
      end
    end

    it "all operations (retrieval, persistence, regular and notifications) should be instantiated" do
      @instantiated_queue.each do |operation|
        operation.should_not be_a Class
      end
    end
  end
end
