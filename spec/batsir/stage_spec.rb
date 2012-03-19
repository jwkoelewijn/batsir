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

  it "should initially set the flag that the stage has been built to false" do
    stage = Batsir::Stage.new
    stage.should_not be_built
  end

  it "should set a flag that the stage has been built" do
    stage = Batsir::Stage.new
    stage.build.should be_true

    stage.should be_built
  end

  it "should initially not have an operation queue" do
    stage = Batsir::Stage.new
    stage.operation_queue.should be_nil
  end

  it "should create an operation queue during the stage build" do
    stage = Batsir::Stage.new
    stage.build.should be_true

    stage.operation_queue.should_not be_nil
  end

  it "should add no operations when no operation type mappings exist" do
    stage = Batsir::Stage.new
    stage.build.should be_true

    stage.operation_queue.should_not be_nil

    operation_queue = stage.operation_queue
    operation_queue.should be_empty
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

end
