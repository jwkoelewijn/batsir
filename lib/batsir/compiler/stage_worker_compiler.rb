module Batsir
  module Compiler
    class StageWorkerCompiler
      attr_accessor :stage

      def initialize(stage)
        @stage = stage
      end

      def compile
        klazz_name = "#{stage.name.capitalize.gsub(' ','')}Worker"
        worker_class_code(klazz_name)
      end

      def worker_class_code(klazz_name)
        code = <<-EOF
          class #{klazz_name}
        EOF

        add_some_methods(code)

        add_filter_queue(code)

        code << <<-EOF
            include Sidekiq::Worker
            include Batsir::StageWorker
          end

          #{klazz_name}.sidekiq_options(:queue => Batsir::Config.sidekiq_queue)
          #{klazz_name}
        EOF
      end

      def add_some_methods(code)
        code << <<-EOF
            def self.stage_name
              "#{stage.name}"
            end

            def initialize
              @filter_queue = self.class.filter_queue
            end

            def self.filter_queue
              @filter_queue
            end
        EOF
      end

      def add_filter_queue(code)
        code << <<-EOF
            def self.initialize_filter_queue
              @filter_queue = Batsir::FilterQueue.new
        EOF

        add_filter_declarations(code)

        add_conditional_notifiers(code)

        add_notifiers(code)

        code << <<-EOF
            end
        EOF
      end

      def add_filter_declarations(code)
        stage.filter_declarations.each do |filter_declaration|
          code << <<-EOF
              @filter_queue.add #{filter_declaration.filter.to_s}.new(#{filter_declaration.options.to_s})
          EOF
        end
      end

      def add_conditional_notifiers(code)
        stage.conditional_notifiers.each do |conditional_notifier_declaration|
          conditional_notifier_declaration.compile(code, self)
        end
      end

      def add_notifiers(code)
        stage.notifiers.each do |notifier, options_set|
          options_set.each do |options|
            code << <<-EOF
              notifier = #{notifier.to_s}.new(#{options.to_s})
            EOF

            self.add_transformers_to_notifier("notifier", code)

            self.add_notifier("notifier", code)
          end
        end
      end

      def add_transformers_to_notifier(notifier_name, code)
        if stage.notifier_transformers.any?
          stage.notifier_transformers.each do |transformer_declaration|
            code << <<-EOF
              #{notifier_name}.add_transformer #{transformer_declaration.transformer}.new(#{transformer_declaration.options.to_s})
            EOF
          end
        else
          code << <<-EOF
              #{notifier_name}.add_transformer Batsir::Transformers::JSONOutputTransformer.new
          EOF
        end
      end

      def add_notifier(notifier_name, code)
        code << <<-EOF
              @filter_queue.add_notifier #{notifier_name}
        EOF
      end
    end
  end
end
