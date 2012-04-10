# Batsir
Batsir is an execution platform for stage based operation queue execution

Batsir uses so called stages to define operation queues. These operation queus
consist of several operations that will be executed one after the other. Each stage
is defined by its name and the queue on which it will listen. Once a message is received
on the queue, it is dispatched to a worker in a seperate thread that will pass the message
to each operation in the operation queue.

Operation queues can have 4 different operations, 1 common operation type, and 3 special 
purpose operations: retrieval operations (which are always executed before all other operations),
persistence operations (which are always executed after the common operations, but before the
notification operations) and notification operations (which will always be executed last)
This makes it possible to create chains of stages to perform tasks that depend on each
other, but otherwise have a low coupling

# Example

```ruby
Batsir.create_and_start do
  retrieval_operation Batsir::RetrievalOperation
  persistence_operation PersistenceOperation
  notification_operation Batsir::NotificationOperation

  stage "stage 1" do
    queue :foo_updated
    object_type Object
    operations do
      add_operation SumOperation
      add_operation AverageOperation
    end
    notifications do
      queue :receive_queue_2, :object_id
    end
  end

  stage "stage 2" do
    queue :receive_queue_2
    object_type String
    operations do
      add_operation SumOperation
    end
  end
end
```

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

