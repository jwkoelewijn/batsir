module Batsir
  class Registry
    def self.register(name, klass)
      registry[name] = klass
    end

    def self.registry
      @registry ||= {}
    end

    def self.get(name)
      registry.fetch(name)
    end
  end
end
