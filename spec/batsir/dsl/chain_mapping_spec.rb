require File.join( File.dirname(__FILE__), "..", "..", "spec_helper")

describe Batsir::DSL::ChainMapping do
  it "should create a chain" do
    block = ::Proc.new do
      aggregator_chain do
      end
    end

    chain = ::Blockenspiel.invoke(block, Batsir::DSL::ChainMapping.new)
    chain.should_not be_nil
  end

  it "should be possible to add a stage" do
    block = ::Proc.new do
      aggregator_chain do
        stage "simple_stage" do

        end
      end
    end

    chain = ::Blockenspiel.invoke(block, Batsir::DSL::ChainMapping.new)
    chain.stages.should_not be_empty
    chain.stages.size.should == 1
    chain.stages.first.name.should == "simple_stage"
  end

  it "should set the chain of the stage to the current chain" do
    block = ::Proc.new do
      aggregator_chain do
        stage "simple_stage" do

        end
      end
    end

    chain = ::Blockenspiel.invoke(block, Batsir::DSL::ChainMapping.new)
    chain.stages.size.should == 1
    chain.stages.first.chain.should == chain
  end

  it "should be possible to add multiple stages" do
    block = ::Proc.new do
      aggregator_chain do
        stage "first_stage" do

        end
        stage "second_stage" do

        end
      end
    end

    chain = ::Blockenspiel.invoke(block, Batsir::DSL::ChainMapping.new)
    chain.stages.should_not be_empty
    chain.stages.size.should == 2
    chain.stages.first.name.should == "first_stage"
    chain.stages.last.name.should == "second_stage"
  end

  it "should be possible to create a complete aggregator chain" do
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
    chain.should_not be_nil
    chain.stages.size.should == 2
    stage1 = chain.stages.first
    stage1.should_not be_nil
    stage1.name.should == stage_name

    stage2 = chain.stages.last
    stage2.should_not be_nil
    stage2.name.should == "#{stage_name}2"

    chain.stages.each do |stage|
      stage.filters.should_not be_nil
      stage.filters.should_not be_empty
      stage.filters.should include operation1
      stage.filters.should include operation2
      stage.notifiers.should_not be_nil
      stage.notifiers.should_not be_empty
      stage.notifiers.should have_key notification_class1
      stage.notifiers[notification_class1].should == options
      stage.notifiers.should have_key notification_class2
      stage.notifiers[notification_class2].should == {}
    end
  end

end
