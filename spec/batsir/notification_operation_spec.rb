require File.join( File.dirname(__FILE__), "..", "spec_helper")

describe Batsir::NotificationOperation do
  it "should respond to #execute" do
    Batsir::NotificationOperation.instance_methods.should include "execute"
  end

  it "should be possible to set the notification queue" do
    notification_queue = :queue
    operation = Batsir::NotificationOperation.new
    operation.queue = notification_queue
    operation.queue.should == notification_queue
  end

  it "should be possible to set the parent attribute" do
    parent_attribute = :parent
    operation = Batsir::NotificationOperation.new
    operation.parent_attribute = parent_attribute
    operation.parent_attribute.should == parent_attribute
  end
end
