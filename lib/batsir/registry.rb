module Batsir
  class Registry
    def self.register(name, klass)
      registry[name] = klass
    end

    def self.registry
      @registry || reset
    end

    def self.get(name)
      registry.fetch(name, nil)
    end

    def self.reset
      @registry = {}
    end
  end
end
