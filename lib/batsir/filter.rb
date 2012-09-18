module Batsir
  class Filter
    def initialize(options = {})
      options.each do |attr, value|
        self.send("#{attr.to_s}=", value)
      end
    end

    def filter(message)
      execute(message)
    end

    def execute(message)
      raise NotImplementedError.new
    end
  end
end
