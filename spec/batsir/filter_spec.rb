require File.join( File.dirname(__FILE__), "..", "spec_helper" )

describe Batsir::Filter do
  it "has an #execute method" do
    Batsir::Filter.instance_methods.map{|im| im.to_s}.should include "execute"
  end

  it "throws an NotImplementedError when #execute method is not overridden" do
    lambda{subject.execute("testing..1..2..3")}.should raise_error NotImplementedError
  end
end
