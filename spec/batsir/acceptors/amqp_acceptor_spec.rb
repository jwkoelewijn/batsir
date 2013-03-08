require File.join( File.dirname(__FILE__), "..", "..",  "spec_helper" )
require File.join( File.dirname(__FILE__), 'shared_examples')

describe Batsir::Acceptors::AMQPAcceptor do
  it_behaves_like "an acceptor", Batsir::Acceptors::AMQPAcceptor

  let(:acceptor_class){
    Batsir::Acceptors::AMQPAcceptor
  }

  context "instantiating" do
    it "sets a bunny pool" do
      acceptor = acceptor_class.new
      acceptor.bunny_pool.should be_kind_of ConnectionPool
    end

    it "uses the same ConnectionPool instance for each acceptor" do
      acceptor1 = acceptor_class.new
      acceptor2 = acceptor_class.new
      acceptor1.should_not eql acceptor2
      acceptor1.bunny_pool.should eql acceptor2.bunny_pool
    end
  end

  context "setting options" do
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

  context "starting the acceptor" do
    def new_acceptor(options = {})
      acceptor_class.new({:queue => :test_queue}.merge options)
    end

    it "starts listening on the configured queue" do
      acceptor = new_acceptor()
      acceptor.start
      acceptor.consumer.queue.name.should == 'test_queue'
    end

    it "connects to the configured host" do
      acceptor = new_acceptor(:host => 'localhost')
      acceptor.start
      acceptor.consumer.queue.channel.connection.host.should == 'localhost'
    end

    it "connects to the configured port" do
      acceptor = new_acceptor(:port => 5672)
      acceptor.start
      acceptor.consumer.queue.channel.connection.port.should == 5672
    end

    it "connects with the configured username" do
      acceptor = new_acceptor(:username => 'guest', :password => 'guest')
      acceptor.start
      acceptor.consumer.queue.channel.connection.user.should == 'guest'
      acceptor.consumer.queue.channel.connection.pass.should == 'guest'
    end

    it "connects to the configured vhost" do
      acceptor = new_acceptor(:vhost => '/')
      acceptor.start
      acceptor.consumer.queue.channel.connection.vhost.should == '/'
    end

    it "declares the configured exchange" do
      acceptor = new_acceptor(:exchange => 'some_exchange')
      acceptor.start
      acceptor.consumer.queue.instance_variable_get(:@bindings).first[:exchange].should == 'some_exchange'
    end

    it "binds the configured exchange to the queue" do
      acceptor = new_acceptor(:exchange => 'some_exchange', :queue => :queue)
      acceptor.start
      binding = acceptor.consumer.queue.instance_variable_get(:@bindings).first
      binding[:exchange].should == 'some_exchange'
      binding[:routing_key].should == :queue
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
      acceptor.consumer.call({})

      acceptor.method_called.should == 1
    end
  end
end
