require File.join( File.dirname(__FILE__), "..", "spec_helper" )

describe Batsir::Filter do
  it "should be possible to create an filter" do
    filter = Batsir::Filter.new
    filter.should_not be_nil
  end

  it "should have an #execute method" do
    Batsir::Filter.instance_methods.map{|im| im.to_s}.should include "execute"
  end
end
