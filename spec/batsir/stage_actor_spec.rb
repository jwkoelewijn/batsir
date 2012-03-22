require File.join( File.dirname(__FILE__), "..", "spec_helper" )

describe Batsir::StageActor do
  it "should be a Celluloid Actor" do
    Batsir::StageActor.new.should be_kind_of Celluloid
  end

  it "should be possible to set an operation queue" do
    operation_queue = Batsir::OperationQueue.new

    stage_actor = Batsir::StageActor.new
    stage_actor.operation_queue = operation_queue
    stage_actor.operation_queue.should == operation_queue
  end

  it "should be possible to set an operation queue in the constructor" do
    operation_queue = Batsir::OperationQueue.new

    stage_actor = Batsir::StageActor.new(:operation_queue => operation_queue)
    stage_actor.operation_queue.should == operation_queue
  end

  it "should be possible to set the queue" do
    operation_queue = Batsir::OperationQueue.new

    stage_actor = Batsir::StageActor.new
    stage_actor.operation_queue = operation_queue
    stage_actor.operation_queue.should == operation_queue
  end

  it "should be possible to set the queue using a proc" do
    stage_actor = Batsir::StageActor.new
    stage_actor.operation_queue = ::Proc.new { Batsir::OperationQueue.new }
    stage_actor.operation_queue.should be_a Batsir::OperationQueue
  end

  context "With respect to executing" do
    before :each do
      chain_options = {
        :retrieval_operation => Batsir::RetrievalOperation,
        :persistence_operation => PersistenceOperation
      }

      chain = Batsir::Chain.new(chain_options)

      stage_options = {
        :queue => :listening_queue,
        :notification_operation => Batsir::NotificationOperation,
        :chain => chain,
        :object_type => Object
      }
      stage = Batsir::Stage.new(stage_options)

      stage.add_operation SumOperation
      stage.add_operation AverageOperation
      stage.add_notification( :notification_queue_1, :parent_id_1 )
      stage.add_notification( :notification_queue_2, :parent_id_2 )
      stage.build.should be_true
      operation_queue = stage.operation_queue
      @instantiated_queue = operation_queue.instantiate_for(stage)
    end

    it "should not execute when no operation queue is set" do
      stage_actor = Batsir::StageActor.new
      stage_actor.execute.should be_false
    end

    it "should not execute when the operation queue is not instantiated" do
      operation_queue = Batsir::OperationQueue.new
      operation_queue.should_not be_instantiated

      stage_actor = Batsir::StageActor.new(:operation_queue => operation_queue)
      stage_actor.execute.should be_false
    end

    it "should execute all operations in the operation queue when an #execute message is received" do
      stage_actor = Batsir::StageActor.new(:operation_queue => @instantiated_queue)
      queue = stage_actor.operation_queue
      queue.each do |operation|
        operation.execute_count.should == 0
      end

      stage_actor.execute.should be_true

      queue.each do |operation|
        operation.execute_count.should == 1
      end
    end
  end
end
