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
      expect(@test.host).to eq('localhost')
    end

    it 'has a port' do
      expect(@test.port).to eq(5672)
    end

    it 'has a username' do
      expect(@test.username).to eq('guest')
    end

    it 'has a password' do
      expect(@test.password).to eq('guest')
    end

    it 'has a vhost' do
      expect(@test.vhost).to eq('/')
    end

    it 'has a exchange' do
      expect(@test.exchange).to eq('amq.direct')
    end

    it 'is durable' do
      expect(@test.durable).to eq(true)
    end

    it 'is undead' do
      expect(@test.heartbeat).to eq(0)
    end
  end

  context 'with respect to setting variables' do
    it 'can change host' do
      localhost = '127.0.0.1'
      @test.host = localhost
      expect(@test.host).to eq(localhost)
    end

    it 'can change heartbeat' do
      hb = 512
      @test.heartbeat = hb
      expect(@test.heartbeat).to eq(hb)
    end
  end
end
