require File.join( File.dirname(__FILE__), "..", "..", "spec_helper")

describe Batsir::DSL::ConditionalNotifierMapping do
  it "adds notifiers" do
    block = lambda do
      conditional do
        notify_if -> { true }, Batsir::Notifiers::Notifier
      end
    end

    conditional = ::Blockenspiel.invoke(block, Batsir::DSL::ConditionalNotifierMapping.new)
    conditional.notifiers.should_not be_empty
    conditional_notifier = conditional.notifiers.first
    conditional_notifier.notifier.should == Batsir::Notifiers::Notifier
  end

  it "passes options to notifiers" do
    block = lambda do
      conditional do
        notify_if ->{ true }, Batsir::Notifiers::Notifier, :some => :options
      end
    end

    conditional = ::Blockenspiel.invoke(block, Batsir::DSL::ConditionalNotifierMapping.new)
    conditional.notifiers.should_not be_empty
    conditional_notifier = conditional.notifiers.first
    conditional_notifier.options.should have_key :some
  end

  it "can be used inside a stage" do
    block = lambda do
      stage "stage name" do
        outbound do
          conditional do
            notify_if ->{ true }, Batsir::Notifiers::Notifier, :some => :options
          end
        end
      end
    end

    stage = ::Blockenspiel.invoke(block, Batsir::DSL::StageMapping.new)
    notifier = stage.notifiers.should_not be_empty
  end
end

