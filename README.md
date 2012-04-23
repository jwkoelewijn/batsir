![Batsir Logo](/jwkoelewijn/batsir/raw/master/batsir.png)

# Batsir
Batsir is an execution platform for stage based filter queue execution.
It is based on the Pipes and Filters patterns, and makes it possible to create
multiples Pipes and Filters (called Stages) that can be invoked asynchronously using so called
inbound Acceptors. Acceptors are started automatically and will send a payload
into the filter chain, after which the (possibly) transformed message will be
processed by the so called outbound Notifiers.
Notifiers can be used to asynchronously send a message to another stage, as long
as corresponding inbound Acceptors have been configured.

This makes it possible to create chains of stages to perform tasks that depend on each
other, but otherwise have a low coupling.

The usage of the Pipes and Filter pattern make it possible to thoroughly test each
filter in isolation, thus promoting fast test cycles.

# Example

```ruby
Batsir.create_and_start do
  stage "stage 1" do
    inbound do
      acceptor AMQPAcceptor, :queue => 'some_queue', :host => 'localhost'
    end
    filter SumFilter
    filter AverageFilter
    outbound do
      notifier AMQPNotifier, :queue => 'queue_2'
    end
  end

  stage "stage 2" do
    inbound do
      acceptor AMQPAcceptor, :queue => 'queue_2'
    end
    filter PrintFilter
  end
end
```

This example creates 2 stages, 'stage 1' and 'stage 2'. The first stage creates and AMQPAcceptor, 
that will connect to a AMQP Broker on localhost and will listen for messages on the 'some_queue' queue.
When a message is received, the message will be offered to the SumFilter first. The result of the
SumFilter is then sent to the #execute method of the AverageFilter. The result of this filter will
than be sent as an AMQP message on the 'queue_2' queue.

The inbound AMQPAcceptor of the second stage will then receive the message and its filters will be
invoked (the PrintFilter in this example).

# Sidekiq & Celluloid
Batsir acts as both a Sidekiq server and client at the same time. When Batsir#create_and_start is invoked,
Batsir will create Sidekiq workers on the fly, with instantiated filters on the workers. These workers will
be deployed in the Sidekiq server, so that they will be available for processing. The workers also register
themselves in a registry, where they can be requested using the stage name.

The inbound acceptors will listen as a Celluloid Actor on the client side of Sidekiq. When a message is 
received, it will look up the corresponding StageWorker in the registry and it will invoke the
StageWorker asynchronously using Sidekiq.

## Contributing to batsir
 
* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it
* Fork the project
* Start a feature/bugfix branch
* Commit and push until you are happy with your contribution
* Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.
* Please try not to mess with the Rakefile, version, or history. If you want to have your own version, or is otherwise necessary, that is fine, but please isolate to its own commit so I can cherry-pick around it.

## Copyright

Copyright (c) 2012 J.W. Koelewijn. See LICENSE.txt for
further details.

