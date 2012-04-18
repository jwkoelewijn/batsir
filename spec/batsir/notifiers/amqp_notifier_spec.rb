require File.join( File.dirname(__FILE__), "..", "..",  "spec_helper" )

describe Batsir::Notifiers::AMQPNotifier do
  let(:notifier_class){
    Batsir::Notifiers::AMQPNotifier
  } 

  context "With respect to setting options" do
    it "should be a Batsir::Notifiers::Notifier" do
      notifier_class.ancestors.should include Batsir::Notifiers::Notifier
    end

    it "should be possible to set the queue on which to listen" do
      notifier = notifier_class.new(:queue => :queue)
      notifier.queue.should == :queue
    end

    it "should be possible to set the host of the amqp broker" do
      notifier = notifier_class.new(:host => 'localhost')
      notifier.host.should == 'localhost'
    end

    it "should be possible to set the port of the amqp broker" do
      notifier = notifier_class.new(:port => 1234)
      notifier.port.should == 1234
    end

    it "should be possible to set the username with which to connect to the broker" do
      notifier = notifier_class.new(:username => 'some_user')
      notifier.username.should == 'some_user'
    end

    it "should be possible to set the password with which to connect to the broker" do
      notifier = notifier_class.new(:password => 'password')
      notifier.password.should == 'password'
    end

    it "should be possible to set the vhost to use on the broker" do
      notifier = notifier_class.new(:vhost => '/')
      notifier.vhost.should == '/'
    end

    it "should be possible to set the exchange to use on the broker" do
      notifier = notifier_class.new(:exchange => 'amq.direct')
      notifier.exchange.should == 'amq.direct'
    end

    it "should default to amqp://guest:guest@localhost:5672/ with direct exchange on vhost ''" do
      notifier = notifier_class.new(:queue => :somequeue)
      notifier.queue.should    == :somequeue
      notifier.host.should     == 'localhost'
      notifier.port.should     == 5672
      notifier.username.should == 'guest'
      notifier.password.should == 'guest'
      notifier.vhost.should    == ''
      notifier.exchange.should == 'amq.direct'
    end
  end

  context "With respect to notifying" do
    def new_notifier(options = {})
      notifier_class.new(options)
    end

    it "should connect to the configured host" do
      notifier = new_notifier(:host => 'somehost')
      notifier.execute({})
      instance = Bunny.instance
      instance.options[:host].should == 'somehost'
    end

    it "should connect to the configured port" do
      notifier = new_notifier(:port => 1234)
      notifier.execute({})
      instance = Bunny.instance
      instance.options[:port].should == 1234
    end

    it "should connect with the configured username" do
      notifier = new_notifier(:username => 'user')
      notifier.execute({})
      instance = Bunny.instance
      instance.options[:user].should == 'user'
    end

    it "should connect with the configured password" do
      notifier = new_notifier(:password => 'pass')
      notifier.execute({})
      instance = Bunny.instance
      instance.options[:pass].should == 'pass'
    end

    it "should connect to the configured vhost" do
      notifier = new_notifier(:vhost => '/vhost')
      notifier.execute({})
      instance = Bunny.instance
      instance.options[:vhost].should == '/vhost'
    end

    it "should declare the configured exchange" do
      notifier = new_notifier(:exchange => 'some_exchange')
      notifier.execute({})
      instance = Bunny.instance
      instance.exchange.name.should == 'some_exchange'
    end

    it "should bind the configured exchange to the queue and publish the message with the queue set as routing key" do
      notifier = new_notifier(:exchange => 'some_exchange', :queue => :queue)
      notifier.execute({})
      instance = Bunny.instance
      instance.exchange.name.should == 'some_exchange'
      instance.exchange.message.should == {}
      instance.exchange.key.should == :queue
    end

  end
end
