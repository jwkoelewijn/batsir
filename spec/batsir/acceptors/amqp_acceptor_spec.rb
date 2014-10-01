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
      expect(acceptor.bunny_pool).to be_kind_of ConnectionPool
    end

    it "uses the same ConnectionPool instance for each acceptor" do
      acceptor1 = acceptor_class.new
      acceptor2 = acceptor_class.new
      expect(acceptor1).not_to eql acceptor2
      expect(acceptor1.bunny_pool).to eql acceptor2.bunny_pool
    end
  end

  context "setting options" do
    it "can set the queue on which to listen" do
      acceptor = acceptor_class.new(:queue => :queue)
      expect(acceptor.queue).to eq(:queue)
    end

    it "can set the host of the amqp broker" do
      acceptor = acceptor_class.new(:host => 'localhost')
      expect(acceptor.host).to eq('localhost')
    end

    it "can set the port of the amqp broker" do
      acceptor = acceptor_class.new(:port => 1234)
      expect(acceptor.port).to eq(1234)
    end

    it "can set the username with which to connect to the broker" do
      acceptor = acceptor_class.new(:username => 'some_user')
      expect(acceptor.username).to eq('some_user')
    end

    it "can set the password with which to connect to the broker" do
      acceptor = acceptor_class.new(:password => 'password')
      expect(acceptor.password).to eq('password')
    end

    it "can set the vhost to use on the broker" do
      acceptor = acceptor_class.new(:vhost => '/vhost')
      expect(acceptor.vhost).to eq('/vhost')
    end

    it "can set the exchange to use on the broker" do
      acceptor = acceptor_class.new(:exchange => 'amq.direct')
      expect(acceptor.exchange).to eq('amq.direct')
    end

    it "can set the queue to be durable" do
      acceptor = acceptor_class.new(:durable => true)
      expect(acceptor.durable).to eq(true)
    end

    it "defaults to amqp://guest:guest@localhost:5672/ with direct exchange on vhost ''" do
      acceptor = acceptor_class.new(:queue => :somequeue)
      expect(acceptor.queue).to    eq(:somequeue)
      expect(acceptor.host).to     eq('localhost')
      expect(acceptor.port).to     eq(5672)
      expect(acceptor.username).to eq('guest')
      expect(acceptor.password).to eq('guest')
      expect(acceptor.vhost).to    eq('/')
      expect(acceptor.exchange).to eq('amq.direct')
    end
  end

  context "starting the acceptor" do
    def new_acceptor(options = {})
      acceptor_class.new({:queue => 'test_queue'}.merge options)
    end

    it "starts listening on the configured queue" do
      acceptor = new_acceptor()
      acceptor.bunny_pool do |bunny|
        expect(acceptor.consumer.queue.name).to eq('test_queue')
      end
    end

    it "connects to the configured host" do
      acceptor = new_acceptor(:host => 'localhost')
      acceptor.start
      expect(acceptor.consumer.queue.channel.connection.host).to eq('localhost')
    end

    it "connects to the configured port" do
      acceptor = new_acceptor(:port => 5672)
      acceptor.start
      expect(acceptor.consumer.queue.channel.connection.port).to eq(5672)
    end

    it "connects with the configured username" do
      acceptor = new_acceptor(:username => 'guest', :password => 'guest')
      acceptor.start
      expect(acceptor.consumer.queue.channel.connection.user).to eq('guest')
      expect(acceptor.consumer.queue.channel.connection.pass).to eq('guest')
    end

    it "connects to the configured vhost" do
      acceptor = new_acceptor(:vhost => '/')
      acceptor.start
      expect(acceptor.consumer.queue.channel.connection.vhost).to eq('/')
    end

    it "declares the configured exchange" do
      acceptor = new_acceptor(:exchange => 'some_exchange')
      acceptor.start
      expect(acceptor.consumer.queue.instance_variable_get(:@bindings).first[:exchange]).to eq('some_exchange')
    end

    it "binds the configured exchange to the queue" do
      acceptor = new_acceptor(:exchange => 'some_exchange', :queue => :queue)
      acceptor.start
      binding = acceptor.consumer.queue.instance_variable_get(:@bindings).first
      expect(binding[:exchange]).to eq('some_exchange')
      expect(binding[:routing_key]).to eq(:queue)
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

      expect(acceptor.method_called).to eq(1)
    end
  end
end
