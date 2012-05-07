module Batsir
  class Stage
    include Celluloid

    FilterDeclaration       = Struct.new(:filter, :options)
    TransformerDeclaration  = Struct.new(:transformer, :options)

    attr_accessor :name
    attr_accessor :chain
    attr_reader   :filter_declarations
    attr_reader   :notifiers
    attr_reader   :acceptors
    attr_reader   :running_acceptors
    attr_reader   :notifier_transformers
    attr_reader   :acceptor_transformers

    def initialize(options = {})
      options.each do |attr, value|
        self.send("#{attr.to_s}=", value)
      end
      @acceptor_transformers  = []
      @running_acceptors      = []
      @acceptors              = {}
      @filter_declarations    = []
      @notifiers              = {}
      @notifier_transformers  = []
      @built                  = false
    end

    def built?
      @built
    end

    def add_acceptor_transformer(transformer, options = {})
      @acceptor_transformers << TransformerDeclaration.new(transformer, options)
    end

    def add_acceptor(acceptor, options = {})
      @acceptors[acceptor] ||= Set.new
      @acceptors[acceptor] << options
    end

    def add_filter(filter, options = {})
      @filter_declarations << FilterDeclaration.new(filter, options)
    end

    def filters
      @filter_declarations.map{ |filter_declaration| filter_declaration.filter }
    end

    def add_notifier(notifier, options = {})
      @notifiers[notifier] ||= Set.new
      @notifiers[notifier] << options
    end

    def add_notifier_transformer(transformer, options = {})
      @notifier_transformers << TransformerDeclaration.new(transformer, options)
    end

    def compile
      Batsir::StageWorker.compile_from(self)
    end

    def finalize
      running_acceptors.each do |acceptor|
        acceptor.terminate! if acceptor.alive?
      end
    end

    def start
      acceptors.each do |acceptor_class, options|
        options.each do |acceptor_options|
          acceptor_options.merge!(:stage_name => self.name)
          acceptor = acceptor_class.new(acceptor_options)
          if acceptor_transformers.any?
            acceptor_transformers.each do |transformer_declaration|
              transformer = transformer_declaration.transformer.new(transformer_declaration.options)
              acceptor.add_transformer(transformer)
            end
          else
            acceptor.add_transformer(Batsir::Transformers::JSONInputTransformer.new)
          end
          @running_acceptors << acceptor
          acceptor.start!
        end
      end
      true
    end
  end
end
