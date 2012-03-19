require File.join( File.dirname(__FILE__), "..", "..", "spec_helper")

describe Batsir::DSL::StageMapping do
  it "should create a simple stage with a name" do
    block = ::Proc.new do
      stage "simple_stage" do
      end
    end

    stage = ::Blockenspiel.invoke(block, Batsir::DSL::StageMapping.new)
    stage.should_not be_nil
    stage.name.should == "simple_stage"
  end

  it "should be possible to set the queue of the stage" do
    queue = :queue

    block = ::Proc.new do
      stage "simple_stage" do
        queue queue
      end
    end

    stage = ::Blockenspiel.invoke(block, Batsir::DSL::StageMapping.new)
    stage.should_not be_nil
    stage.queue.should == queue
  end

  it "should be possible to set the object type of the stage" do
    object_type = Object

    block = ::Proc.new do
      stage "simple_stage" do
        object_type object_type
      end
    end

    stage = ::Blockenspiel.invoke(block, Batsir::DSL::StageMapping.new)
    stage.should_not be_nil
    stage.object_type.should == object_type
  end

  it "should be possible to add an operation to the stage" do
    operation = "Operation"

    block = ::Proc.new do
      stage "simple_stage" do
        operations do
          add_operation operation
        end
      end
    end

    stage = ::Blockenspiel.invoke(block, Batsir::DSL::StageMapping.new)
    stage.should_not be_nil
    stage.operation_queue.should_not be_nil
    stage.operation_queue.should_not be_empty
    stage.operation_queue.should include operation
  end

  it "should be possible to add multiple operations to the stage" do
    operation1 = "Operation 1"
    operation2 = "Operation 2"

    block = ::Proc.new do
      stage "simple_stage" do
        operations do
          add_operation operation1
          add_operation operation2
        end
      end
    end

    stage = ::Blockenspiel.invoke(block, Batsir::DSL::StageMapping.new)
    stage.should_not be_nil
    stage.operation_queue.should_not be_nil
    stage.operation_queue.should_not be_empty
    stage.operation_queue.should include operation1
    stage.operation_queue.should include operation2
  end

  it "should be possible to add a notification queue to the stage" do
    notification_queue = :notification_queue
    parent_attribute = :parent

    block = ::Proc.new do
      stage "simple_stage" do
        notifications do
          queue notification_queue, parent_attribute
        end
      end
    end

    stage = ::Blockenspiel.invoke(block, Batsir::DSL::StageMapping.new)
    stage.should_not be_nil
    stage.notification_queues.should_not be_empty
    stage.notification_queues.should have_key notification_queue
    stage.notification_queues[notification_queue].should == parent_attribute
  end

  it "should be possible to add multiple notification queues to the stage" do
    notification_queue1 = :notification_queue1
    parent_attribute1   = :parent1
    notification_queue2 = :notification_queue2
    parent_attribute2   = :parent2

    block = ::Proc.new do
      stage "simple_stage" do
        notifications do
          queue notification_queue1, parent_attribute1
          queue notification_queue2, parent_attribute2
        end
      end
    end

    stage = ::Blockenspiel.invoke(block, Batsir::DSL::StageMapping.new)
    stage.should_not be_nil
    stage.notification_queues.should_not be_empty
    stage.notification_queues.should have_key notification_queue1
    stage.notification_queues[notification_queue1].should == parent_attribute1

    stage.notification_queues.should have_key notification_queue2
    stage.notification_queues[notification_queue2].should == parent_attribute2
  end

  it "should be possible to create a complete stage" do
    stage_name          = "Complete Stage"
    receiving_queue     = :receiving_queue
    object_type         = Object
    operation1          = "Some Operation"
    operation2          = "Another Operation"
    notification_queue1 = :notification_queue1
    parent_attribute1   = :parent1
    notification_queue2 = :notification_queue2
    parent_attribute2   = :parent2

    block = ::Proc.new do
      stage stage_name do
        queue receiving_queue
        object_type object_type
        operations do
          add_operation operation1
          add_operation operation2
        end
        notifications do
          queue notification_queue1, parent_attribute1
          queue notification_queue2, parent_attribute2
        end
      end
    end

    stage = ::Blockenspiel.invoke(block, Batsir::DSL::StageMapping.new)
    stage.should_not be_nil
    stage.name.should == stage_name
    stage.queue.should == receiving_queue
    stage.object_type.should == object_type
    stage.operation_queue.should_not be_nil
    stage.operation_queue.should_not be_empty
    stage.operation_queue.should include operation1
    stage.operation_queue.should include operation2
    stage.notification_queues.should_not be_nil
    stage.notification_queues.should_not be_empty
    stage.notification_queues.should have_key notification_queue1
    stage.notification_queues[notification_queue1].should == parent_attribute1

    stage.notification_queues.should have_key notification_queue2
    stage.notification_queues[notification_queue2].should == parent_attribute2
 end
end
