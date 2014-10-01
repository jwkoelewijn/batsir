require File.join( File.dirname(__FILE__), "..", "..",  "spec_helper" )
require File.join( File.dirname(__FILE__), 'shared_examples')

describe Batsir::Notifiers::ConditionalNotifier do

  it_should_behave_like "a notifier", Batsir::Notifiers::ConditionalNotifier

  true_block = ::Proc.new { |message| true }

  let(:notifier){ Batsir::Notifiers::Notifier }

  it "can add notifiers" do
    expect(subject.notifiers.size).to eq(0)
    subject.add_notifier( true_block, notifier)
    expect(subject.notifiers.size).to eq(1)
  end

  it "stores notifier conditions" do
    subject.add_notifier(true_block, notifier)

    notifier_condition = subject.notifiers.first
    expect(notifier_condition).to be_a Batsir::Notifiers::ConditionalNotifier::NotifierCondition
    expect(notifier_condition.condition).to eq(true_block)
    expect(notifier_condition.notifier).to eq(notifier)
  end

  it "stores optional options for the notifier" do
    subject.add_notifier( true_block, notifier, :some => :extra, :options => :foryou)

    notifier_condition = subject.notifiers.first
    expect(notifier_condition.options.size).to eq(2)
    expect(notifier_condition.options).to have_key :some
    expect(notifier_condition.options).to have_key :options
  end

  context "sending messages" do
    class FakeNotifier < Batsir::Notifiers::Notifier; end

    it "executes notifiers if condition is true" do

      notifier_class = FakeNotifier
      allow_any_instance_of(notifier_class).to receive(:execute)
      expect_any_instance_of(notifier_class).to receive(:execute)

      conditional = Batsir::Notifiers::ConditionalNotifier.new
      conditional.add_notifier( true_block, notifier_class.new({}) )
      conditional.execute("some message")
    end

    it "does not execute when condition is false" do
      false_block = lambda {|message| false}

      notifier_class = FakeNotifier
      allow_any_instance_of(notifier_class).to receive(:execute)
      expect_any_instance_of(notifier_class).not_to receive(:execute)

      conditional = Batsir::Notifiers::ConditionalNotifier.new
      conditional.add_notifier( false_block, notifier_class.new({}) )
      conditional.execute("some message")
    end
  end
end
