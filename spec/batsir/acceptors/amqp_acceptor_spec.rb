require File.join( File.dirname(__FILE__), "..", "..",  "spec_helper" )
require File.join( File.dirname(__FILE__), 'shared_examples')

describe Batsir::Acceptors::AMQPAcceptor do
  it_behaves_like "an acceptor", Batsir::Acceptors::AMQPAcceptor

  let(:acceptor_class){
    Batsir::Acceptors::AMQPAcceptor
  }

  context "with respect to setting options" do
    it "can set the queue on which to listen" do
      acceptor = acceptor_class.new(:queue => :queue)
      acceptor.queue.should == :queue
    end

    it "can set the host of the amqp broker" do
      acceptor = acceptor_class.new(:host => 'localhost')
      acceptor.host.should == 'localhost'
    end

    it "can set the port of the amqp broker" do
      acceptor = acceptor_class.new(:port => 1234)
      acceptor.port.should == 1234
    end

    it "can set the username with which to connect to the broker" do
      acceptor = acceptor_class.new(:username => 'some_user')
      acceptor.username.should == 'some_user'
    end

    it "can set the password with which to connect to the broker" do
      acceptor = acceptor_class.new(:password => 'password')
      acceptor.password.should == 'password'
    end

    it "can set the vhost to use on the broker" do
      acceptor = acceptor_class.new(:vhost => '/vhost')
      acceptor.vhost.should == '/vhost'
    end

    it "can set the exchange to use on the broker" do
      acceptor = acceptor_class.new(:exchange => 'amq.direct')
      acceptor.exchange.should == 'amq.direct'
    end

    it "defaults to amqp://guest:guest@localhost:5672/ with direct exchange on vhost ''" do
      acceptor = acceptor_class.new(:queue => :somequeue)
      acceptor.queue.should    == :somequeue
      acceptor.host.should     == 'localhost'
      acceptor.port.should     == 5672
      acceptor.username.should == 'guest'
      acceptor.password.should == 'guest'
      acceptor.vhost.should    == '/'
      acceptor.exchange.should == 'amq.direct'
    end
  end

  context "with respect to starting the acceptor" do
    def new_acceptor(options = {})
      acceptor_class.new(options)
    end

    it "connects to the configured host" do
      acceptor = new_acceptor(:host => 'somehost')
      acceptor.start
      instance = Bunny.instance
      instance.options[:host].should == 'somehost'
    end

    it "connects to the configured port" do
      acceptor = new_acceptor(:port => 1234)
      acceptor.start
      instance = Bunny.instance
      instance.options[:port].should == 1234
    end

    it "connects with the configured username" do
      acceptor = new_acceptor(:username => 'user')
      acceptor.start
      instance = Bunny.instance
      instance.options[:user].should == 'user'
    end

    it "connects with the configured password" do
      acceptor = new_acceptor(:password => 'pass')
      acceptor.start
      instance = Bunny.instance
      instance.options[:pass].should == 'pass'
    end

    it "connects to the configured vhost" do
      acceptor = new_acceptor(:vhost => '/vhost')
      acceptor.start
      instance = Bunny.instance
      instance.options[:vhost].should == '/vhost'
    end

    it "declares the configured exchange" do
      acceptor = new_acceptor(:exchange => 'some_exchange')
      acceptor.start
      instance = Bunny.instance
      instance.exchange.name.should == 'some_exchange'
    end

    it "binds the configured exchange to the queue" do
      acceptor = new_acceptor(:exchange => 'some_exchange', :queue => :queue)
      acceptor.start
      instance = Bunny.instance
      queue = instance.queues[:queue]
      queue.bound_exchange.name.should == 'some_exchange'
      queue.bound_key.should == :queue
    end

    it "starts listening on the configured queue" do
      acceptor = new_acceptor(:queue => :some_queue)
      acceptor.start
      instance = Bunny.instance
      instance.queues.size.should == 1
      instance.queues.keys.should include :some_queue
    end

    it "initialises the subscription with the acceptor's cancellator" do
      cancellator = :cancellator
      acceptor = new_acceptor(:queue => :some_queue, :cancellator => cancellator)
      acceptor.start
      instance = Bunny.instance
      instance.queues[:some_queue].arguments.first[:cancellator].should == cancellator
    end

    it "calls the #start_filter_chain method when a message is received" do
      acceptor = new_acceptor(:queue => :some_queue)

      # Because acceptor is a Celluloid Actor, it is not possible to define a method
      # on the instance directly, because you actually hold a reference to a
      # ActorProxy.
      # Fortunately, ActorProxy defines the #_send_ method, which we can use to
      # define a singleton_method on the actual proxied instance.
      # We cannot just redefine the class method here, because it will break other
      # tests.

      start_filter_chain_mock_method = lambda do |message|
        @method_called ||= 0
        @method_called += 1
      end

      method_called_mock_method = lambda do
        @method_called ||= 0
      end

      acceptor._send_(:define_singleton_method, :start_filter_chain, start_filter_chain_mock_method)
      acceptor._send_(:define_singleton_method, :method_called, method_called_mock_method)

      acceptor.start

      instance = Bunny.instance
      queue = instance.queues[:some_queue]
      queue.should_not be_nil

      block = queue.block
      block.call({})

      acceptor.method_called.should == 1
    end
  end
end
