module Batsir
  module DSL
    class ChainMapping < ::Blockenspiel::Base
      def initialize
        @chain = nil
      end

      def aggregator_chain(&block)
        @chain = Batsir::Chain.new
        ::Blockenspiel.invoke(block, self)
        @chain
      end

      def retrieval_operation(operation)
        @chain.retrieval_operation = operation
      end

      def persistence_operation(operation)
        @chain.persistence_operation = operation
      end

      def stage(name, &block)
        new_block = ::Proc.new do
          stage name, &block
        end
        stage = ::Blockenspiel.invoke(new_block, Batsir::DSL::StageMapping.new)
        @chain.add_stage(stage)
      end
    end

    class StageMapping < ::Blockenspiel::Base
      def initialize
        @stage = nil
      end

      def stage(name, &block)
        @stage = Batsir::Stage.new(:name => name)
        ::Blockenspiel.invoke(block, self)
        @stage
      end

      def queue(queue)
        @stage.queue = queue
      end

      def object_type(object_type)
        @stage.object_type = object_type
      end

      def operations(&block)
        ::Blockenspiel.invoke(block, self)
      end

      def add_operation(operation)
        @stage.add_operation(operation)
      end

      def notifications(&block)
        ::Blockenspiel.invoke(block, Batsir::DSL::NotificationMapping.new(@stage))
      end
    end

    class NotificationMapping < ::Blockenspiel::Base
      def initialize(stage)
        @stage = stage
      end

      def queue(notification_queue, parent_attribute)
        @stage.add_notification(notification_queue, parent_attribute)
      end
    end
  end
end
