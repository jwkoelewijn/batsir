module Batsir
  class Filter
    def initialize(options = {})
      options.each do |attr, value|
        self.send("#{attr.to_s}=", value)
      end
    end

    def execute(message)
    end
  end
end
