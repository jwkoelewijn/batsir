0.3.1
-----------
- Renamed config variable 'connection_pool_size' to a more apt 'amqp_pool_size'


0.3.0
-----------
- AMQPAcceptor and AMQPNotifier classes now only support Bunny 0.9 and up.
  This fixes a bug that occurred when talking to an AMQP 0.9 server with a Bunny 0.8 client.
  High message rates would, at some point, cause the server to reject all messages.


0.2.1
-----------
- Notifiers will not modify the message
- FieldTransformers now always return message hashes with strings for keys


0.2.0
-----------
- first production-ready code
