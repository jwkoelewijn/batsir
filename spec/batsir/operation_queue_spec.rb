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
    queue.persistence_operation = operation
    queue.persistence_operation.should == operation
  end

  it "should place persist operations to the back of the queue" do
    queue = Batsir::OperationQueue.new
    operation = "FakePersistOperation"
    queue.persistence_operation = operation

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

    queue.persistence_operation = "SomePersistOperation"
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

    queue.persistence_operation = "SomePersistOperation"

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
    queue.persistence_operation = "SomePersistOperation"

    queue.should_not be_empty
  end

  it "should not be empty when a regular operation is added" do
    queue = Batsir::OperationQueue.new

    queue.add("SomeOperation")
    queue.should_not be_empty
  end
end
