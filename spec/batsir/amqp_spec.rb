require File.join( File.dirname(__FILE__), "..", "spec_helper" )

describe Batsir::AMQP do
  before :all do
    class AMQPTest
      include Batsir::AMQP
    end
    @test = AMQPTest.new
  end

  context 'with respect to default variables' do
    it 'has a host' do
      @test.host.should == 'localhost'
    end

    it 'has a port' do
      @test.port.should == 5672
    end

    it 'has a username' do
      @test.username.should == 'guest'
    end

    it 'has a password' do
      @test.password.should == 'guest'
    end

    it 'has a vhost' do
      @test.vhost.should == '/'
    end

    it 'has a exchange' do
      @test.exchange.should == 'amq.direct'
    end

    it 'is durable' do
      @test.durable.should == true
    end

    it 'is undead' do
      @test.heartbeat.should == 0
    end
  end

  context 'with respect to setting variables' do
    it 'can change host' do
      localhost = '127.0.0.1'
      @test.host = localhost
      @test.host.should == localhost
    end

    it 'can change heartbeat' do
      hb = 512
      @test.heartbeat = hb
      @test.heartbeat.should == hb
    end
  end
end
