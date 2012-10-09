module Batsir
  module DSL
    class ConditionalNotifierDeclaration
      attr_reader :notifier_declarations

      NotifierConditionDeclaration = Struct.new(:condition, :notifier, :options)

      def initialize
        @notifier_declarations = []
      end

      def add_conditional(condition, notifier_class, options)
        @notifier_declarations << NotifierConditionDeclaration.new(condition, notifier_class, options)
      end

      def compile(output, stage_worker)
        output << <<-EOF
              conditional_notifier = Batsir::Notifiers::ConditionalNotifier.new
        EOF
        notifier_declarations.each do |notifier_declaration|
          output << <<-EOF
              condition = ->(message){#{notifier_declaration.condition}}
              conditional_notifier.add_notifier condition, #{notifier_declaration.notifier}.new(#{notifier_declaration.options.to_s})
          EOF
        end
        stage_worker.add_transformers_to_notifier("conditional_notifier", output)
        stage_worker.add_notifier( "conditional_notifier", output)
      end
    end
  end
end
