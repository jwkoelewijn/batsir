require File.join( File.dirname(__FILE__), "..", "spec_helper" )

describe Batsir::StageWorker do
  context "with respect to including the StageWorker module" do
    before :all do
      class TestWorker
        def self.stage_name
          @stage_name_called = true
          "TestWorker"
        end

        def self.stage_name_called
          @stage_name_called || false
        end

        def self.initialize_filter_queue
          @initialization_count ||= 0
          @initialization_count += 1
        end

        def self.initialization_count
          @initialization_count
        end

        include Batsir::StageWorker
      end
    end
      
    it "should register workers once they include the stage worker" do
      Batsir::Registry.get("TestWorker").should == TestWorker
    end

    it "should call the queue initialization method" do
      TestWorker.initialization_count.should == 1
    end

    it "should call the stage name class method to register itself under" do
      TestWorker.stage_name_called.should be_true
    end
  end

  it "should be possible to set an filter queue" do
    Batsir::StageWorker.instance_methods.map{|m| m.to_s}.should include "filter_queue="
  end

  context "With respect to executing" do
    before :all do
      class TestWorker
        def self.stage_name
          "TestWorker"
        end

        def self.intitialize_filter_queue
          @initialization_count ||= 0
          @initialization_count += 1
        end

        def initialization_count
          @initialization_count
        end

        include Batsir::StageWorker
      end
    end

    before :each do
      chain = Batsir::Chain.new

      stage_options = {
        :chain => chain,
      }
      stage = Batsir::Stage.new(stage_options)

      stage.add_filter SumOperation
      stage.add_filter AverageOperation
      stage.add_notifier( :notification_queue_1, {:queue => :somequeue} )
      stage.add_notifier( :notification_queue_2 )
    end

    it "should not execute when no operation queue is set" do
      stage_actor = TestWorker.new
      stage_actor.execute({}).should be_false
    end

    it "should execute all operations in the operation queue when an #execute message is received" do
      filter_queue = Batsir::FilterQueue.new
      filter_queue.add SumOperation.new
      filter_queue.add AverageOperation.new

      stage_actor = TestWorker.new
      stage_actor.filter_queue = filter_queue

      queue = stage_actor.filter_queue
      queue.each do |filter|
        filter.execute_count.should == 0
      end

      stage_actor.execute({}).should be_true

      queue.each do |filter|
        filter.execute_count.should == 1
      end
    end
  end
end
