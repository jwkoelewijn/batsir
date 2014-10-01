0.4.0
-----------
- Removes support for MRI 1.9.3
- Worker class compilation has been refactored
- Limits Celluloid < 0.16.0
  Higher versions may prevent Sidekiq from cleanly shutting down.
- Removes bunny and sidekiq constraints

0.3.7
-----------
- AMQP queues are now durable by default.
  This prevents queued messages getting lost when batsir is restarted (and the last consumer disconnects). It can be configured by setting 'Batsir::Config.amqp_durable'.
- Now requires bunny 0.10.7


0.3.6
-----------
- Fixes bug in conditional notifier
- Constrained Celluloid version to 0.14.x, until we can support 0.15.x and above


0.3.5
-----------
- NOTICE: This version removes sidekiq/celluloid gem contraints. Be sure to set these accordingly in your own project's Gemfile!


0.3.4
-----------
- Fixed issue when using bunny 0.9.0.pre9. Bunny::Session#start now returns ifself instead of its channel.


0.3.3
-----------
- Bunny :heartbeat option is now explicitly set. It defaults to 0; the original AMQP 0.8 setting.


0.3.2
-----------
- Filters can now be passed initialisation options


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
