require File.join( File.dirname(__FILE__), "..", "spec_helper" )

describe Batsir::Filter do
  it "has an #execute method" do
    expect(Batsir::Filter.instance_methods.map{|im| im.to_s}).to include "execute"
  end

  it "throws an NotImplementedError when #execute method is not overridden" do
    expect{subject.execute("testing..1..2..3")}.to raise_error NotImplementedError
  end
end
