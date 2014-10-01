require File.join( File.dirname(__FILE__), "..", "..", "spec_helper")

describe Batsir::DSL::ChainMapping do
  it "creates a chain" do
    block = ::Proc.new do
      aggregator_chain do
      end
    end

    chain = ::Blockenspiel.invoke(block, Batsir::DSL::ChainMapping.new)
    expect(chain).not_to be_nil
  end

  it "can add a stage" do
    block = ::Proc.new do
      aggregator_chain do
        stage "simple_stage" do

        end
      end
    end

    chain = ::Blockenspiel.invoke(block, Batsir::DSL::ChainMapping.new)
    expect(chain.stages).not_to be_empty
    expect(chain.stages.size).to eq(1)
    expect(chain.stages.first.name).to eq("simple_stage")
  end

  it "sets the chain of the stage to the current chain" do
    block = ::Proc.new do
      aggregator_chain do
        stage "simple_stage" do

        end
      end
    end

    chain = ::Blockenspiel.invoke(block, Batsir::DSL::ChainMapping.new)
    expect(chain.stages.size).to eq(1)
    expect(chain.stages.first.chain).to eq(chain)
  end

  it "can add multiple stages" do
    block = ::Proc.new do
      aggregator_chain do
        stage "first_stage" do

        end
        stage "second_stage" do

        end
      end
    end

    chain = ::Blockenspiel.invoke(block, Batsir::DSL::ChainMapping.new)
    expect(chain.stages).not_to be_empty
    expect(chain.stages.size).to eq(2)
    expect(chain.stages.first.name).to eq("first_stage")
    expect(chain.stages.last.name).to eq("second_stage")
  end

  it "can create a complete aggregator chain" do
    stage_name            = "Complete Stage"
    operation1            = "Some Operation"
    operation2            = "Another Operation"
    notification_class1   = :notification_class1
    options               = {:queue => :somequeue}
    notification_class2   = :notification_class2

    block = ::Proc.new do
      aggregator_chain do
        stage stage_name do
          filter operation1
          filter operation2
          outbound do
            notifier notification_class1, options
            notifier notification_class2
          end
        end

        stage "#{stage_name}2" do
          filter operation1
          filter operation2
          outbound do
            notifier notification_class1, options
            notifier notification_class2
          end
        end
      end
    end

    chain = ::Blockenspiel.invoke(block, Batsir::DSL::ChainMapping.new)
    expect(chain).not_to be_nil
    expect(chain.stages.size).to eq(2)
    stage1 = chain.stages.first
    expect(stage1).not_to be_nil
    expect(stage1.name).to eq(stage_name)

    stage2 = chain.stages.last
    expect(stage2).not_to be_nil
    expect(stage2.name).to eq("#{stage_name}2")

    chain.stages.each do |stage|
      expect(stage.filters).not_to be_nil
      expect(stage.filters).not_to be_empty
      expect(stage.filters).to include operation1
      expect(stage.filters).to include operation2
      expect(stage.notifiers).not_to be_nil
      expect(stage.notifiers).not_to be_empty
      expect(stage.notifiers).to have_key notification_class1
      expect(stage.notifiers[notification_class1].first).to eq(options)
      expect(stage.notifiers).to have_key notification_class2
      expect(stage.notifiers[notification_class2].first).to eq({})
    end
  end
end
