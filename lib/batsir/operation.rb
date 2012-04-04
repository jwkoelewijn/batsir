module Batsir
  class Operation
    def initialize(options = {})
      options.each do |attr, value|
        self.send("#{attr.to_s}=", value)
      end
    end

    def execute(*args)
    end
  end
end
