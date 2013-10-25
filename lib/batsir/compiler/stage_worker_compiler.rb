module Batsir
  module Compiler
    class StageWorkerCompiler
      attr_accessor :stage

      def initialize(stage)
        @stage = stage
      end

      def compile
        klazz_name = "#{stage.name.capitalize.gsub(' ','')}Worker"
        compile_worker_class(klazz_name)
      end

      def compile_worker_class(klazz_name)
        worker_class(klazz_name) do |code|
          stage.filter_declarations.each do |filter_declaration|
            add_filter(filter_declaration, code)
          end

          stage.conditional_notifiers.each do |conditional_notifier_declaration|
            conditional_notifier_declaration.compile(code, self)
          end

          stage.notifiers.each do |notifier, options_set|
            options_set.each do |options|
              new_notifier(notifier, options, code)
              add_transformers_to_notifier(code)
              add_notifier(code)
            end
          end
        end
      end

      def worker_class(klazz_name, &block)
        code = <<-EOF
          class #{klazz_name}
            def self.stage_name
              "#{stage.name}"
            end

            def initialize
              @filter_queue = self.class.filter_queue
            end

            def self.filter_queue
              @filter_queue
            end

            def self.initialize_filter_queue
              @filter_queue = Batsir::FilterQueue.new
        EOF

        yield code

        code << <<-EOF
            end

            include Sidekiq::Worker
            include Batsir::StageWorker
          end

          #{klazz_name}.sidekiq_options(:queue => Batsir::Config.sidekiq_queue)
          #{klazz_name}
        EOF
      end

      def add_filter(filter_declaration, code)
        code << <<-EOF
            @filter_queue.add #{filter_declaration.filter.to_s}.new(#{filter_declaration.options.to_s})
        EOF
      end

      def new_notifier(notifier, options, code)
        code << <<-EOF
          notifier = #{notifier.to_s}.new(#{options.to_s})
        EOF
      end

      def add_transformers_to_notifier(code)
        if stage.notifier_transformers.any?
          stage.notifier_transformers.each do |transformer_declaration|
            code << <<-EOF
              notifier.add_transformer #{transformer_declaration.transformer}.new(#{transformer_declaration.options.to_s})
            EOF
          end
        else
          code << <<-EOF
              notifier.add_transformer Batsir::Transformers::JSONOutputTransformer.new
          EOF
        end
      end

      def add_notifier(code)
        code << <<-EOF
              @filter_queue.add_notifier notifier
        EOF
      end
    end
  end
end
