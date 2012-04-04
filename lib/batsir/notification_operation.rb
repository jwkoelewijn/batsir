module Batsir
  class NotificationOperation < Operation
    attr_accessor :queue
    attr_accessor :parent_attribute

    def execute(msg)
      Bunny.run do | bunny|
        direct_exchange = bunny.exchange("")
        direct_exchange.publish("test", :key => queue)
      end
    end
  end
end
