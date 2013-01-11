require File.join( File.dirname(__FILE__), "..", "..",  "spec_helper" )
require File.join( File.dirname(__FILE__), 'shared_examples')

describe Batsir::Notifiers::AMQPNotifier do
  let(:notifier_class){
    Batsir::Notifiers::AMQPNotifier
  }

  def new_notifier(options = {})
    notifier_class.new(options)
  end

  it_should_behave_like "a notifier", Batsir::Notifiers::AMQPNotifier

  context "with respect to setting options" do
    it "is a Batsir::Notifiers::Notifier" do
      notifier_class.ancestors.should include Batsir::Notifiers::Notifier
    end

    it "can set the queue on which to listen" do
      notifier = notifier_class.new(:queue => :queue)
      notifier.queue.should == :queue
    end

    it "can set the host of the amqp broker" do
      notifier = notifier_class.new(:host => 'localhost')
      notifier.host.should == 'localhost'
    end

    it "can set the port of the amqp broker" do
      notifier = notifier_class.new(:port => 1234)
      notifier.port.should == 1234
    end

    it "can set the username with which to connect to the broker" do
      notifier = notifier_class.new(:username => 'some_user')
      notifier.username.should == 'some_user'
    end

    it "can set the password with which to connect to the broker" do
      notifier = notifier_class.new(:password => 'password')
      notifier.password.should == 'password'
    end

    it "can set the vhost to use on the broker" do
      notifier = notifier_class.new(:vhost => '/blah')
      notifier.vhost.should == '/blah'
    end

    it "can set the exchange to use on the broker" do
      notifier = notifier_class.new(:exchange => 'amq.direct')
      notifier.exchange.should == 'amq.direct'
    end

    it "defaults to amqp://guest:guest@localhost:5672/ with direct exchange on vhost ''" do
      notifier = notifier_class.new(:queue => :somequeue)
      notifier.queue.should    == :somequeue
      notifier.host.should     == 'localhost'
      notifier.port.should     == 5672
      notifier.username.should == 'guest'
      notifier.password.should == 'guest'
      notifier.vhost.should    == '/'
      notifier.exchange.should == 'amq.direct'
    end
  end

  context "with respect to notifying" do
    it 'has an #execute method' do
      notifier_class.instance_methods.map{|m| m.to_s}.should include "execute"
    end

    it 'has a #handle_error method' do
      notifier_class.instance_methods.map{|m| m.to_s}.should include "handle_error"
    end

    it "connects to the configured host" do
      notifier = new_notifier(:host => 'somehost')
      notifier.execute({})
      instance = Bunny.instance
      instance.options[:host].should == 'somehost'
    end

    it "connects to the configured port" do
      notifier = new_notifier(:port => 1234)
      notifier.execute({})
      instance = Bunny.instance
      instance.options[:port].should == 1234
    end

    it "connects with the configured username" do
      notifier = new_notifier(:username => 'user')
      notifier.execute({})
      instance = Bunny.instance
      instance.options[:user].should == 'user'
    end

    it "connects with the configured password" do
      notifier = new_notifier(:password => 'pass')
      notifier.execute({})
      instance = Bunny.instance
      instance.options[:pass].should == 'pass'
    end

    it "connects to the configured vhost" do
      notifier = new_notifier(:vhost => '/vhost')
      notifier.execute({})
      instance = Bunny.instance
      instance.options[:vhost].should == '/vhost'
    end

    it "declares the configured exchange" do
      notifier = new_notifier(:exchange => 'some_exchange')
      notifier.execute({})
      instance = Bunny.instance
      instance.exchange.name.should == 'some_exchange'
    end

    it "binds the configured exchange to the queue and publish the message with the queue set as routing key" do
      notifier = new_notifier(:exchange => 'some_exchange', :queue => :queue)
      notifier.execute({})
      instance = Bunny.instance
      instance.exchange.name.should == 'some_exchange'
      instance.exchange.message.should == {}
      instance.exchange.key.should == :queue
    end
  end

  context "with respect to error handling" do
    it 'uses a strategy object to resolve notification errors' do
      notifier = new_notifier(:exchange => 'some_exchange', :queue => :queue)
      notifier.error_strategy.should be_a Batsir::Strategies::RetryStrategy
    end
  end
end
