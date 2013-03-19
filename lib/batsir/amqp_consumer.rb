module Batsir
  class AMQPConsumer < Bunny::Consumer
    def initialize(acceptor, channel, queue)
      super(channel, queue)
      @acceptor = acceptor
    end
  end
end
