require File.join( File.dirname(__FILE__), "..", "..",  "spec_helper" )
require File.join( File.dirname(__FILE__), 'shared_examples')

describe Batsir::Notifiers::ConditionalNotifier do

  it_should_behave_like "notifier", Batsir::Notifiers::ConditionalNotifier

  true_block = ::Proc.new { |message| true }

  let(:notifier){ Batsir::Notifiers::Notifier }

  it "can add notifiers" do
    subject.notifiers.size.should == 0
    subject.add_notifier( true_block, notifier)
    subject.notifiers.size.should == 1
  end

  it "stores notifier conditions" do
    subject.add_notifier(true_block, notifier)

    notifier_condition = subject.notifiers.first
    notifier_condition.should be_a Batsir::Notifiers::ConditionalNotifier::NotifierCondition
    notifier_condition.condition.should == true_block
    notifier_condition.notifier.should == notifier
  end

  it "stores optional options for the notifier" do
    subject.add_notifier( true_block, notifier, :some => :extra, :options => :foryou)

    notifier_condition = subject.notifiers.first
    notifier_condition.options.size.should == 2
    notifier_condition.options.should have_key :some
    notifier_condition.options.should have_key :options
  end

  context "sending messages" do
    class FakeNotifier < Batsir::Notifiers::Notifier; end

    it "executes notifiers if condition is true" do

      notifier_class = FakeNotifier
      notifier_class.any_instance.stub(:execute)
      notifier_class.any_instance.should_receive(:execute)

      conditional = Batsir::Notifiers::ConditionalNotifier.new
      conditional.add_notifier( true_block, notifier_class )
      conditional.execute("some message")
    end

    it "does not execute when condition is false" do
      false_block = lambda {|message| false}

      notifier_class = FakeNotifier
      notifier_class.any_instance.stub(:execute)
      notifier_class.any_instance.should_not_receive(:execute)

      conditional = Batsir::Notifiers::ConditionalNotifier.new
      conditional.add_notifier( false_block, notifier_class )
      conditional.execute("some message")
    end
  end
end
