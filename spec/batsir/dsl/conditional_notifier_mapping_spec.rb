require File.join( File.dirname(__FILE__), "..", "..", "spec_helper")

describe Batsir::DSL::ConditionalNotifierMapping do
  it "creates conditional notifier declarations" do
    block = lambda do
      conditional do
        notify_if "message == 'sometext'", Batsir::Notifiers::Notifier
      end
    end

    conditional = ::Blockenspiel.invoke(block, Batsir::DSL::ConditionalNotifierMapping.new)
    expect(conditional.notifier_declarations).not_to be_empty
    conditional_notifier = conditional.notifier_declarations.first
    expect(conditional_notifier.notifier).to eq(Batsir::Notifiers::Notifier)
  end

  it "passes options to notifiers" do
    block = lambda do
      conditional do
        notify_if "true", Batsir::Notifiers::Notifier, :some => :options
      end
    end

    conditional = ::Blockenspiel.invoke(block, Batsir::DSL::ConditionalNotifierMapping.new)
    expect(conditional.notifier_declarations).not_to be_empty
    conditional_notifier = conditional.notifier_declarations.first
    expect(conditional_notifier.options).to have_key :some
  end

  it "can be used inside a stage" do
    block = lambda do
      stage "stage name" do
        outbound do
          conditional do
            notify_if "true", Batsir::Notifiers::Notifier, :some => :options
          end
        end
      end
    end

    stage = ::Blockenspiel.invoke(block, Batsir::DSL::StageMapping.new)
    notifier = expect(stage.conditional_notifiers).not_to be_empty
  end

  context "compiling" do
    before :all do
      Celluloid.boot

      block = lambda do
        stage "stage name" do
          outbound do
            conditional do
              notify_if "true", Batsir::Notifiers::Notifier
              notify_if "false", Batsir::Notifiers::Notifier
            end
          end
        end
      end

      stage = ::Blockenspiel.invoke(block, Batsir::DSL::StageMapping.new)
      created_class = eval( stage.compile )
      @instance = created_class.new
    end

    it "stores the conditional notifier" do
      @instance.filter_queue.notifiers.size == 1
      conditional = @instance.filter_queue.notifiers.first
      expect(conditional).to be_kind_of Batsir::Notifiers::ConditionalNotifier
      expect(conditional.notifiers.size).to eq(2)
      expect(conditional.notifiers.first.condition).to be_a Proc
    end

    it "adds the default transformer" do
      notifier = @instance.filter_queue.notifiers.first
      expect(notifier.transformer_queue.size).to eq(1)
      expect(notifier.transformer_queue.first).to be_kind_of Batsir::Transformers::Transformer
    end
  end
end

