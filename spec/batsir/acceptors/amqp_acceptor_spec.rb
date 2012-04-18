require File.join( File.dirname(__FILE__), "..", "..",  "spec_helper" )

describe Batsir::Acceptors::AMQPAcceptor do

  let(:acceptor_class){
    Batsir::Acceptors::AMQPAcceptor
  }

  context "With respect to setting options" do

    it "should be a Batsir::Acceptors::Acceptor" do
      acceptor_class.ancestors.should include Batsir::Acceptors::Acceptor
    end

    it "should be possible to set the queue on which to listen" do
      acceptor = acceptor_class.new(:queue => :queue)
      acceptor.queue.should == :queue
    end

    it "should be possible to set the host of the amqp broker" do
      acceptor = acceptor_class.new(:host => 'localhost')
      acceptor.host.should == 'localhost'
    end

    it "should be possible to set the port of the amqp broker" do
      acceptor = acceptor_class.new(:port => 1234)
      acceptor.port.should == 1234
    end

    it "should be possible to set the username with which to connect to the broker" do
      acceptor = acceptor_class.new(:username => 'some_user')
      acceptor.username.should == 'some_user'
    end

    it "should be possible to set the password with which to connect to the broker" do
      acceptor = acceptor_class.new(:password => 'password')
      acceptor.password.should == 'password'
    end

    it "should be possible to set the vhost to use on the broker" do
      acceptor = acceptor_class.new(:vhost => '/vhost')
      acceptor.vhost.should == '/vhost'
    end

    it "should be possible to set the exchange to use on the broker" do
      acceptor = acceptor_class.new(:exchange => 'amq.direct')
      acceptor.exchange.should == 'amq.direct'
    end

    it "should default to amqp://guest:guest@localhost:5672/ with direct exchange on vhost ''" do
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

    it "should connect to the configured host" do
      acceptor = new_acceptor(:host => 'somehost')
      acceptor.start
      instance = Bunny.instance
      instance.options[:host].should == 'somehost'
    end

    it "should connect to the configured port" do
      acceptor = new_acceptor(:port => 1234)
      acceptor.start
      instance = Bunny.instance
      instance.options[:port].should == 1234
    end

    it "should connect with the configured username" do
      acceptor = new_acceptor(:username => 'user')
      acceptor.start
      instance = Bunny.instance
      instance.options[:user].should == 'user'
    end

    it "should connect with the configured password" do
      acceptor = new_acceptor(:password => 'pass')
      acceptor.start
      instance = Bunny.instance
      instance.options[:pass].should == 'pass'
    end

    it "should connect to the configured vhost" do
      acceptor = new_acceptor(:vhost => '/vhost')
      acceptor.start
      instance = Bunny.instance
      instance.options[:vhost].should == '/vhost'
    end

    it "should declare the configured exchange" do
      acceptor = new_acceptor(:exchange => 'some_exchange')
      acceptor.start
      instance = Bunny.instance
      instance.exchange.name.should == 'some_exchange'
    end

    it "should bind the configured exchange to the queue" do
      acceptor = new_acceptor(:exchange => 'some_exchange', :queue => :queue)
      acceptor.start
      instance = Bunny.instance
      queue = instance.queues[:queue]
      queue.bound_exchange.name.should == 'some_exchange'
      queue.bound_key.should == :queue
    end

    it "should start listening on the configured queue" do
      acceptor = new_acceptor(:queue => :some_queue)
      acceptor.start
      instance = Bunny.instance
      instance.queues.size.should == 1
      instance.queues.keys.should include :some_queue
    end

    it "should call the #start_filter_chain method when a message is received" do
      class Batsir::Acceptors::Acceptor
        def start_filter_chain(message)
          @@method_called ||= 0
          @@method_called += 1
        end

        def self.method_called
          @@method_called ||= 0
        end
      end
      acceptor = new_acceptor(:queue => :some_queue)
      acceptor.start
      instance = Bunny.instance
      queue = instance.queues[:some_queue]
      queue.should_not be_nil

      Batsir::Acceptors::Acceptor.method_called.should == 0

      message = {}
      block = queue.block
      block.call(message)

      Batsir::Acceptors::Acceptor.method_called.should == 1
    end
  end
end
