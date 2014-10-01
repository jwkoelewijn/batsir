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
      expect(notifier_class.ancestors).to include Batsir::Notifiers::Notifier
    end

    it "can set the queue on which to listen" do
      notifier = notifier_class.new(:queue => :queue)
      expect(notifier.queue).to eq(:queue)
    end

    it "can set the host of the amqp broker" do
      notifier = notifier_class.new(:host => 'localhost')
      expect(notifier.host).to eq('localhost')
    end

    it "can set the port of the amqp broker" do
      notifier = notifier_class.new(:port => 1234)
      expect(notifier.port).to eq(1234)
    end

    it "can set the username with which to connect to the broker" do
      notifier = notifier_class.new(:username => 'some_user')
      expect(notifier.username).to eq('some_user')
    end

    it "can set the password with which to connect to the broker" do
      notifier = notifier_class.new(:password => 'password')
      expect(notifier.password).to eq('password')
    end

    it "can set the vhost to use on the broker" do
      notifier = notifier_class.new(:vhost => '/blah')
      expect(notifier.vhost).to eq('/blah')
    end

    it "can set the exchange to use on the broker" do
      notifier = notifier_class.new(:exchange => 'amq.direct')
      expect(notifier.exchange).to eq('amq.direct')
    end

    it "defaults to amqp://guest:guest@localhost:5672/ with direct exchange on vhost ''" do
      notifier = notifier_class.new(:queue => :somequeue)
      expect(notifier.queue).to    eq(:somequeue)
      expect(notifier.host).to     eq('localhost')
      expect(notifier.port).to     eq(5672)
      expect(notifier.username).to eq('guest')
      expect(notifier.password).to eq('guest')
      expect(notifier.vhost).to    eq('/')
      expect(notifier.exchange).to eq('amq.direct')
    end
  end

  context "with respect to notifying" do
    before :each do
      Batsir::Registry.reset
    end

    it 'has an #execute method' do
      expect(notifier_class.instance_methods.map{|m| m.to_s}).to include "execute"
    end

    it 'has a #handle_error method' do
      expect(notifier_class.instance_methods.map{|m| m.to_s}).to include "handle_error"
    end

    it "connects to the configured host" do
      notifier = new_notifier(:host => 'somehost')
      notifier.execute({})
      instance = Bunny.instance
      expect(instance.options[:host]).to eq('somehost')
    end

    it "connects to the configured port" do
      notifier = new_notifier(:port => 1234)
      notifier.execute({})
      instance = Bunny.instance
      expect(instance.options[:port]).to eq(1234)
    end

    it "connects with the configured username" do
      notifier = new_notifier(:username => 'user')
      notifier.execute({})
      instance = Bunny.instance
      expect(instance.user).to eq('user')
    end

    it "connects with the configured password" do
      notifier = new_notifier(:password => 'pass')
      notifier.execute({})
      instance = Bunny.instance
      expect(instance.options[:pass]).to eq('pass')
    end

    it "connects to the configured vhost" do
      notifier = new_notifier(:vhost => '/vhost')
      notifier.execute({})
      instance = Bunny.instance
      expect(instance.options[:vhost]).to eq('/vhost')
    end

    it "declares the configured exchange" do
      notifier = new_notifier(:exchange => 'some_exchange')
      notifier.execute({})
      instance = Bunny.instance
      expect(instance.exchange.name).to eq('some_exchange')
    end

    it "binds the configured exchange to the queue and publish the message with the queue set as routing key" do
      notifier = new_notifier(:exchange => 'some_exchange', :queue => :queue)
      notifier.execute({})
      instance = Bunny.instance
      expect(instance.exchange.name).to eq('some_exchange')
      expect(instance.exchange.message).to eq({})
      expect(instance.exchange.key).to eq(:queue)
    end
  end

  context "with respect to error handling" do
    it 'uses a strategy object to resolve notification errors' do
      notifier = new_notifier(:exchange => 'some_exchange', :queue => :queue)
      expect(notifier.error_strategy).to be_a Batsir::Strategies::RetryStrategy
    end
  end
end
