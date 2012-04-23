module Batsir
  class Stage
    include Celluloid

    FilterDeclaration = Struct.new(:filter, :options)

    attr_accessor :name
    attr_accessor :chain
    attr_reader   :filter_declarations
    attr_reader   :notifiers
    attr_reader   :acceptors

    def initialize(options = {})
      options.each do |attr, value|
        self.send("#{attr.to_s}=", value)
      end
      @acceptors           = {}
      @filter_declarations = []
      @notifiers           = {}
      @built               = false
    end

    def built?
      @built
    end

    def add_notifier(notifier, options = {})
      @notifiers[notifier] ||= Set.new
      @notifiers[notifier] << options
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

    def compile
      Batsir::StageWorker.compile_from(self)
    end

    def start
      acceptors.each do |acceptor_class, options|
        options.each do |acceptor_options|
          acceptor_options.merge!(:stage_name => self.name)
          acceptor = acceptor_class.new(acceptor_options)
          acceptor.start!
        end
      end
      true
    end
  end
end
