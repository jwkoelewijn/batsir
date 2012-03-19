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

  it "should place the retrieval operation in front of all other operations" do
    queue = Batsir::OperationQueue.new
    operation = "NotificationOperation"

    queue.add("SomeOperation")
    queue.add_notification_operation(operation)
    queue.add("AnotherOperation")

    queue.persist_operation = "SomePersistOperation"
    queue.retrieval_operation = "RetrievalOperation"

    queue.first.should == "RetrievalOperation"
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

end
