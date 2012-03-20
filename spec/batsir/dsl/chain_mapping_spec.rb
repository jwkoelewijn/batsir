require File.join( File.dirname(__FILE__), "..", "..", "spec_helper")

describe Batsir::DSL::ChainMapping do
  it "should create a chain" do
    block = ::Proc.new do
      aggregator_chain do
      end
    end

    chain = ::Blockenspiel.invoke(block, Batsir::DSL::ChainMapping.new)
    chain.should_not be_nil
  end

  it "should be possible to set a retrieval operation" do
    retrieval_op = "Retrieval operation"

    block = ::Proc.new do
      aggregator_chain do
        retrieval_operation retrieval_op
      end
    end

    chain = ::Blockenspiel.invoke(block, Batsir::DSL::ChainMapping.new)
    chain.retrieval_operation.should == retrieval_op
  end

  it "should be possible to set a persistence operation" do
    persistence_op = "Persistence operation"

    block = ::Proc.new do
      aggregator_chain do
        persistence_operation persistence_op
      end
    end

    chain = ::Blockenspiel.invoke(block, Batsir::DSL::ChainMapping.new)
    chain.persistence_operation.should == persistence_op
  end

  it "should be possible to set a notification operation" do
    notification_op = "Persistence operation"

    block = ::Proc.new do
      aggregator_chain do
        notification_operation notification_op
      end
    end

    chain = ::Blockenspiel.invoke(block, Batsir::DSL::ChainMapping.new)
    chain.notification_operation.should == notification_op
  end

  it "should be possible to add a stage" do
    block = ::Proc.new do
      aggregator_chain do
        stage "simple_stage" do

        end
      end
    end

    chain = ::Blockenspiel.invoke(block, Batsir::DSL::ChainMapping.new)
    chain.stages.should_not be_empty
    chain.stages.size.should == 1
    chain.stages.first.name.should == "simple_stage"
  end

  it "should set the chain of the stage to the current chain" do
    block = ::Proc.new do
      aggregator_chain do
        stage "simple_stage" do

        end
      end
    end

    chain = ::Blockenspiel.invoke(block, Batsir::DSL::ChainMapping.new)
    chain.stages.size.should == 1
    chain.stages.first.chain.should == chain
  end

  it "should be possible to add multiple stages" do
    block = ::Proc.new do
      aggregator_chain do
        stage "first_stage" do

        end
        stage "second_stage" do

        end
      end
    end

    chain = ::Blockenspiel.invoke(block, Batsir::DSL::ChainMapping.new)
    chain.stages.should_not be_empty
    chain.stages.size.should == 2
    chain.stages.first.name.should == "first_stage"
    chain.stages.last.name.should == "second_stage"
  end

  it "should make sure stages use the chain retrieval operation when no stage specific one is set" do
    retrieval_operation = "Retrieval Operation"
    block = ::Proc.new do
      aggregator_chain do
        retrieval_operation retrieval_operation

        stage "simple_stage" do
        end
      end
    end

    chain = ::Blockenspiel.invoke(block, Batsir::DSL::ChainMapping.new)
    chain.stages.size.should == 1
    chain.stages.first.retrieval_operation.should == retrieval_operation
  end

  it "should make sure stages use the chain persistence operation when no stage specific one is set" do
    persistence_operation = "Persistence Operation"
    block = ::Proc.new do
      aggregator_chain do
        persistence_operation persistence_operation

        stage "simple_stage" do
        end
      end
    end

    chain = ::Blockenspiel.invoke(block, Batsir::DSL::ChainMapping.new)
    chain.stages.size.should == 1
    chain.stages.first.persistence_operation.should == persistence_operation
  end

  it "should use a stage specific retrieval operation when it is set" do
    chain_retrieval_operation = "Chain Retrieval Operation"
    stage_retrieval_operation = "Stage Retrieval Operation"

    block = ::Proc.new do
      aggregator_chain do
        retrieval_operation chain_retrieval_operation

        stage "simple_stage" do
          retrieval_operation stage_retrieval_operation
        end
      end
    end

    chain = ::Blockenspiel.invoke(block, Batsir::DSL::ChainMapping.new)
    chain.retrieval_operation.should == chain_retrieval_operation
    chain.stages.size.should == 1
    chain.stages.first.retrieval_operation.should == stage_retrieval_operation
  end

  it "should use a stage specific persistence operation when it is set" do
    chain_persistence_operation = "Chain Persistence Operation"
    stage_persistence_operation = "Stage Persistence Operation"

    block = ::Proc.new do
      aggregator_chain do
        persistence_operation chain_persistence_operation

        stage "simple_stage" do
          persistence_operation stage_persistence_operation
        end
      end
    end

    chain = ::Blockenspiel.invoke(block, Batsir::DSL::ChainMapping.new)
    chain.persistence_operation.should == chain_persistence_operation
    chain.stages.size.should == 1
    chain.stages.first.persistence_operation.should == stage_persistence_operation
  end

  it "should use a stage specific notification operation when it is set" do
    chain_notification_operation = "Chain Persistence Operation"
    stage_notification_operation = "Stage Persistence Operation"

    block = ::Proc.new do
      aggregator_chain do
        notification_operation chain_notification_operation

        stage "simple_stage" do
          notification_operation stage_notification_operation
        end
      end
    end

    chain = ::Blockenspiel.invoke(block, Batsir::DSL::ChainMapping.new)
    chain.notification_operation.should == chain_notification_operation
    chain.stages.size.should == 1
    chain.stages.first.notification_operation.should == stage_notification_operation
  end

  it "should be possible to create a complete aggregator chain" do
    retrieval_operation   = "Retrieval Operation"
    persistence_operation = "Persistence Operation"
    stage_name            = "Complete Stage"
    receiving_queue       = :receiving_queue
    object_type           = Object
    operation1            = "Some Operation"
    operation2            = "Another Operation"
    notification_queue1   = :notification_queue1
    parent_attribute1     = :parent1
    notification_queue2   = :notification_queue2
    parent_attribute2     = :parent2

    block = ::Proc.new do
      aggregator_chain do
        retrieval_operation retrieval_operation
        persistence_operation persistence_operation

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

        stage "#{stage_name}2" do
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
    end

    chain = ::Blockenspiel.invoke(block, Batsir::DSL::ChainMapping.new)
    chain.should_not be_nil
    chain.retrieval_operation.should == retrieval_operation
    chain.persistence_operation.should == persistence_operation
    chain.stages.size.should == 2
    stage1 = chain.stages.first
    stage1.should_not be_nil
    stage1.name.should == stage_name

    stage2 = chain.stages.last
    stage2.should_not be_nil
    stage2.name.should == "#{stage_name}2"

    chain.stages.each do |stage|
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

end
