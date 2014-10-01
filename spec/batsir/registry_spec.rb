require File.join( File.dirname(__FILE__), "..", "spec_helper" )

describe Batsir::Registry do

  before :all do
    @class = Batsir::Registry
  end

  before :each do
    @class.reset
  end

  it "outputs the whole registry" do
    expect(@class.registry).to eq({})
  end

  it "registers a value" do
    @class.register(:foo, :bar)
    expect(@class.registry.keys.size).to eq(1)
    expect(@class.registry.keys).to include :foo
    expect(@class.registry.values.size).to eq(1)
    expect(@class.registry.values).to include :bar
  end

  it "is able to retrieve a registered variable" do
    @class.register('test', 'value')
    expect(@class.get('test')).to eq('value')
  end

  it "returns nil when the requested key is not found" do
    expect(@class.get('foobar')).to be_nil
  end

  context "resetting" do
    it "is possible" do
      @class.register('foo', 'bar')
      expect(@class.registry).to eq({'foo' => 'bar'})
      @class.reset
      expect(@class.registry).to eq({})
    end

    it "returns its new state" do
      @class.register('foo', 'bar')
      result = @class.reset
      expect(result).to eq({})
    end
  end
end
