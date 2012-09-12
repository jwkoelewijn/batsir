require File.join( File.dirname(__FILE__), "..", "spec_helper" )

describe Batsir::FilterQueue do
  it "can add a filter to a queue" do
    queue = Batsir::FilterQueue.new
    queue.add("Filter")
    queue.should include "Filter"
  end

  it "does not return nil as last operation when no acceptors or notifiers are added" do
    queue = Batsir::FilterQueue.new
    queue.add("AnotherFilter")
    ops = []
    queue.each do |op|
      ops << op
    end
    ops.last.should_not be_nil
  end

  it "can add a notifier" do
    queue = Batsir::FilterQueue.new
    notifier = "Notifier"
    queue.add_notifier(notifier)
    queue.should include notifier
  end

  it "can add multiple notifiers" do
    queue = Batsir::FilterQueue.new
    ops = []
    3.times do |index|
      ops << "Notifier #{index}"
      queue.add_notifier("Notifier #{index}")
    end
    ops.each {|op| queue.should include op}
  end

  it "returns notifiers as the last operations" do
    notifier = "Notifier"
    queue = Batsir::FilterQueue.new
    queue.add("SomeFilter")
    queue.add_notifier(notifier)
    queue.add("AnotherFilter")

    ops = []
    queue.each do |op|
      ops << op
    end
    ops.last.should == notifier
  end

  it "responds true to #empty? when no operations are added" do
    queue = Batsir::FilterQueue.new
    queue.should be_empty
  end

  it "is not empty when a notification operation is added" do
    queue = Batsir::FilterQueue.new
    operation = "Notifier"
    queue.add_notifier(operation)
    queue.should_not be_empty
  end

  it "is not empty when a regular operation is added" do
    queue = Batsir::FilterQueue.new
    queue.add("SomeFilter")
    queue.should_not be_empty
  end
end
