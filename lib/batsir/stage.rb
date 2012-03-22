module Batsir
  class Stage
    include Celluloid

    attr_accessor :name
    attr_accessor :queue
    attr_accessor :object_type
    attr_accessor :chain
    attr_accessor :retrieval_operation
    attr_accessor :persistence_operation
    attr_accessor :notification_operation
    attr_reader   :operation_queue
    attr_reader   :notification_queues
    attr_reader   :stage_actor_pool

    def initialize(options = {})
      options.each do |attr, value|
        self.send("#{attr.to_s}=", value)
      end
      @notification_queues = {}
      @stage_actor_pool = []
      @built = false
    end

    def retrieval_operation
      @retrieval_operation || (chain ? chain.retrieval_operation : nil)
    end

    def persistence_operation
      @persistence_operation || (chain ? chain.persistence_operation : nil)
    end

    def notification_operation
      @notification_operation || (chain ? chain.notification_operation : nil)
    end

    def built?
      @built
    end

    def add_notification(notification_queue, parent_attribute)
      @notification_queues[notification_queue] = parent_attribute
    end

    def add_operation(operation)
      @operation_queue ||= OperationQueue.new
      @operation_queue.add(operation)
    end

    def build
      return false unless (chain && queue && object_type)

      @operation_queue ||= OperationQueue.new
      @stage_actor_pool = Celluloid::Pool.supervise_as(:stage_actor_pool,
        Batsir::StageActor,
        :max_size => 5,
        :args => [{:operation_queue => lambda { @operation_queue.instantiate_for(self)}}]
      ).actor

      @built = true
    end

    def start
      return false unless built?
      Bunny.run do | bunny |
        q = bunny.queue(self.queue)
        exc = bunny.exchange('')
        q.subscribe do |msg|
          @stage_actor_pool.get do |actor|
            actor.execute!(msg)
          end
        end
      end
      true
    end

    def instantiate_operation_queue
      @operation_queue ||= OperationQueue.new
      @operation_queue.instantiate_for(self)
    end
  end
end
