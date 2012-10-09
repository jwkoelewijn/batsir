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

      def stage(name, &block)
        new_block = ::Proc.new do
          stage name, &block
        end
        stage = ::Blockenspiel.invoke(new_block, Batsir::DSL::StageMapping.new)
        stage.chain = @chain
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

      def filter(operation)
        @stage.add_filter(operation)
      end

      def inbound(&block)
        ::Blockenspiel.invoke(block, Batsir::DSL::InboundMapping.new(@stage))
      end

      def outbound(&block)
        ::Blockenspiel.invoke(block, Batsir::DSL::OutboundMapping.new(@stage))
      end

    end

    class InboundMapping < ::Blockenspiel::Base
      def initialize(stage)
        @stage = stage
      end

      def transformers(&block)
        ::Blockenspiel.invoke(block, Batsir::DSL::InboundTransformerMapping.new(@stage))
      end

      def acceptor(acceptor_class, options = {})
        @stage.add_acceptor(acceptor_class, options)
      end
    end

    class InboundTransformerMapping < ::Blockenspiel::Base
      def initialize(stage)
        @stage = stage
      end

      def transformer(transformer, options = {})
        @stage.add_acceptor_transformer(transformer, options)
      end
    end

    class OutboundMapping < ::Blockenspiel::Base
      def initialize(stage)
        @stage = stage
      end

      def transformers(&block)
        ::Blockenspiel.invoke(block, Batsir::DSL::OutboundTransformerMapping.new(@stage))
      end

      def conditional(&block)
        new_block = ::Proc.new do
          conditional &block
        end
        conditional = ::Blockenspiel.invoke(new_block, Batsir::DSL::ConditionalNotifierMapping.new)
        @stage.add_conditional_notifier(conditional)
      end

      def notifier(notifier_class, options = {})
        @stage.add_notifier(notifier_class, options)
      end
    end

    class OutboundTransformerMapping < ::Blockenspiel::Base
      def initialize(stage)
        @stage = stage
      end

      def transformer(transformer, options = {})
        @stage.add_notifier_transformer(transformer, options)
      end
    end

    class ConditionalNotifierMapping < ::Blockenspiel::Base
      def initialize
        @notifier = nil
      end

      def conditional(&block)
        @notifier = Batsir::DSL::ConditionalNotifierDeclaration.new
        ::Blockenspiel.invoke(block, self)
        @notifier
      end

      def notify_if(condition, notifier, options = {})
        @notifier.add_conditional(condition, notifier, options)
      end
    end
  end
end
