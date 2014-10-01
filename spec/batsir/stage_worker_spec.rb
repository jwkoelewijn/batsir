require File.join( File.dirname(__FILE__), "..", "spec_helper" )

describe Batsir::StageWorker do
  it "can set a filter queue" do
    expect(Batsir::StageWorker.instance_methods.map{|m| m.to_s}).to include "filter_queue="
  end

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

    it "registers workers once they include the stage worker" do
      expect(Batsir::Registry.get("TestWorker")).to eq(TestWorker)
    end

    it "calls the queue initialization method" do
      expect(TestWorker.initialization_count).to eq(1)
    end

    it "calls the stage name class method to register itself under" do
      expect(TestWorker.stage_name_called).to be_truthy
    end
  end

  context "with respect to executing" do
    before :all do
      class TestWorker
        def self.stage_name
          "TestWorker"
        end

        def self.intitialize_filter_queue
          @initialization_count ||= 0
          @initialization_count += 1
        end

        include Batsir::StageWorker
      end

      class TestNotifier
        def notify(message)
          @notify_count ||= 0
          @notify_count += 1
        end

        def notify_count
          @notify_count ||= 0
        end
      end
    end

    before :each do
      chain = Batsir::Chain.new

      stage_options = {
        :chain => chain,
      }
      stage = Batsir::Stage.new(stage_options)

      stage.add_filter SumFilter
      stage.add_filter AverageFilter
      stage.add_notifier( :notification_queue_1, {:queue => :somequeue} )
      stage.add_notifier( :notification_queue_2 )
    end

    it "does not execute when no operation queue is set" do
      stage_worker = TestWorker.new
      expect(stage_worker.execute({})).to be_falsey
    end

    it "executes all operations in the operation queue when an #execute message is received" do
      filter_queue = Batsir::FilterQueue.new
      filter_queue.add SumFilter.new
      filter_queue.add AverageFilter.new

      stage_worker = TestWorker.new
      stage_worker.filter_queue = filter_queue

      queue = stage_worker.filter_queue
      queue.each do |filter|
        expect(filter.execute_count).to eq(0)
      end

      expect(stage_worker.execute({})).to be_truthy

      queue.each do |filter|
        expect(filter.execute_count).to eq(1)
      end
    end

    it "calls #notify on all notifiers in the filter queue when an #execute message is received" do
      filter_queue = Batsir::FilterQueue.new
      filter_queue.add_notifier TestNotifier.new

      stage_worker = TestWorker.new
      stage_worker.filter_queue = filter_queue

      notifier = filter_queue.notifiers.first
      expect(notifier).not_to be_nil
      expect(notifier.notify_count).to eq(0)

      expect(stage_worker.execute({})).to be_truthy

      expect(notifier.notify_count).to eq(1)
    end
  end
end
