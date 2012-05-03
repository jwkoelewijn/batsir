require File.join( File.dirname(__FILE__), "..", "..", "spec_helper")

describe Batsir::DSL::StageMapping do
  it "should create a simple stage with a name" do
    block = ::Proc.new do
      stage "simple_stage" do
      end
    end

    stage = ::Blockenspiel.invoke(block, Batsir::DSL::StageMapping.new)
    stage.should_not be_nil
    stage.name.should == "simple_stage"
  end

  it "should be possible to add an filter to the stage" do
    filter = "Operation"

    block = ::Proc.new do
      stage "simple_stage" do
        filter filter
      end
    end

    stage = ::Blockenspiel.invoke(block, Batsir::DSL::StageMapping.new)
    stage.should_not be_nil
    stage.filters.should_not be_nil
    stage.filters.should_not be_empty
    stage.filters.should include filter
  end

  it "should be possible to add multiple filters to the stage" do
    filter1 = "Operation 1"
    filter2 = "Operation 2"

    block = ::Proc.new do
      stage "simple_stage" do
        filter filter1
        filter filter2
      end
    end

    stage = ::Blockenspiel.invoke(block, Batsir::DSL::StageMapping.new)
    stage.should_not be_nil
    stage.filters.should_not be_nil
    stage.filters.should_not be_empty
    stage.filters.should include filter1
    stage.filters.should include filter2
  end

  it "should be possible to add an inbound section to a stage" do
    block = ::Proc.new do
      stage "simple_stage" do
        inbound do

        end
      end
    end

    stage = ::Blockenspiel.invoke(block, Batsir::DSL::StageMapping.new)
    stage.should_not be_nil
    stage.acceptors.should_not be_nil
    stage.acceptors.should be_empty
  end

  it "should be possible to add a transformers section to the inbound section of a stage" do
    block = ::Proc.new do
      stage "simple_stage" do
        inbound do
          transformers do

          end
        end
      end
    end

    stage = ::Blockenspiel.invoke(block, Batsir::DSL::StageMapping.new)
    stage.should_not be_nil
    stage.acceptors.should_not be_nil
    stage.acceptors.should be_empty
    stage.acceptor_transformers.should be_empty
  end

  it "should be possible to add a transformer to the transformers section of the inbound section of a stage" do
    transformer = :transformer

    block = ::Proc.new do
      stage "simple_stage" do
        inbound do
          transformers do
            transformer transformer
          end
        end
      end
    end

    stage = ::Blockenspiel.invoke(block, Batsir::DSL::StageMapping.new)
    stage.should_not be_nil
    stage.acceptors.should_not be_nil
    stage.acceptors.should be_empty
    stage.acceptor_transformers.should_not be_empty
    stage.acceptor_transformers.size.should == 1
    stage.acceptor_transformers.first.transformer.should == transformer
  end

  it "should be possible to add a transformer with options to the transformers section of the inbound section of a stage" do
    transformer = :transformer
    options     = {:foo => :bar}

    block = ::Proc.new do
      stage "simple_stage" do
        inbound do
          transformers do
            transformer transformer, options
          end
        end
      end
    end

    stage = ::Blockenspiel.invoke(block, Batsir::DSL::StageMapping.new)
    stage.should_not be_nil
    stage.acceptors.should_not be_nil
    stage.acceptors.should be_empty
    stage.acceptor_transformers.should_not be_empty
    stage.acceptor_transformers.size.should == 1
    stage.acceptor_transformers.first.transformer.should == transformer
    stage.acceptor_transformers.first.options.should == options
  end

  it "should be possible to add multiple transformers to the transformers section of the inbound section of a stage" do
    transformer1 = :transformer1
    options     = {:foo => :bar}
    transformer2 = :transformer2

    block = ::Proc.new do
      stage "simple_stage" do
        inbound do
          transformers do
            transformer transformer1, options
            transformer transformer2
          end
        end
      end
    end

    stage = ::Blockenspiel.invoke(block, Batsir::DSL::StageMapping.new)
    stage.should_not be_nil
    stage.acceptors.should_not be_nil
    stage.acceptors.should be_empty
    stage.acceptor_transformers.should_not be_empty
    stage.acceptor_transformers.size.should == 2
    stage.acceptor_transformers.first.transformer.should == transformer1
    stage.acceptor_transformers.first.options.should == options
    stage.acceptor_transformers.last.transformer.should == transformer2
    stage.acceptor_transformers.last.options.should == {}
  end

  it "should be possible to add an acceptor to a stage" do
    acceptor_class = :acceptor_class

    block = ::Proc.new do
      stage "simple_stage" do
        inbound do
          acceptor acceptor_class
        end
      end
    end

    stage = ::Blockenspiel.invoke(block, Batsir::DSL::StageMapping.new)
    stage.should_not be_nil
    stage.acceptors.should_not be_nil
    stage.acceptors.should_not be_empty
    stage.acceptors.keys.should include acceptor_class
    stage.acceptors[acceptor_class].first.should == {}
  end

  it "should be possible to add an inbound section with an acceptor with options to the stage" do
    acceptor_class = :acceptor_class
    options = {:foo => :bar}

    block = ::Proc.new do
      stage "simple_stage" do
        inbound do
          acceptor acceptor_class, options
        end
      end
    end

    stage = ::Blockenspiel.invoke(block, Batsir::DSL::StageMapping.new)
    stage.should_not be_nil
    stage.acceptors.should_not be_nil
    stage.acceptors.should_not be_empty
    stage.acceptors.keys.should include acceptor_class
    stage.acceptors[acceptor_class].first.should == options
  end

  it "should be possible to add multiple acceptors to a stage" do
    acceptor_class1 = :acceptor_class1
    options = {:foo => :bar}
    acceptor_class2 = :acceptor_class2

    block = ::Proc.new do
      stage "simple_stage" do
        inbound do
          acceptor acceptor_class1, options
          acceptor acceptor_class2
        end
      end
    end

    stage = ::Blockenspiel.invoke(block, Batsir::DSL::StageMapping.new)
    stage.should_not be_nil
    stage.acceptors.should_not be_nil
    stage.acceptors.should_not be_empty
    stage.acceptors.keys.should include acceptor_class1
    stage.acceptors[acceptor_class1].first.should == options
    stage.acceptors.keys.should include acceptor_class2
    stage.acceptors[acceptor_class2].first.should == {}
  end

  it "should be possible to add an outbound section without any notifiers" do
    block = ::Proc.new do
      stage "simple_stage" do
        outbound do

        end
      end
    end

    stage = ::Blockenspiel.invoke(block, Batsir::DSL::StageMapping.new)
    stage.should_not be_nil
    stage.notifiers.should_not be_nil
    stage.notifiers.should be_empty
  end

  it "should be possible to add a transformers section to the outbound section of a stage" do
    block = ::Proc.new do
      stage "simple_stage" do
        outbound do
          transformers do

          end
        end
      end
    end

    stage = ::Blockenspiel.invoke(block, Batsir::DSL::StageMapping.new)
    stage.should_not be_nil
    stage.notifiers.should_not be_nil
    stage.notifiers.should be_empty
    stage.notifier_transformers.should be_empty
  end

  it "should be possible to add a transformer to the transformers section of the outbound section of a stage" do
    transformer = :transformer

    block = ::Proc.new do
      stage "simple_stage" do
        outbound do
          transformers do
            transformer transformer
          end
        end
      end
    end

    stage = ::Blockenspiel.invoke(block, Batsir::DSL::StageMapping.new)
    stage.should_not be_nil
    stage.notifiers.should_not be_nil
    stage.notifiers.should be_empty
    stage.notifier_transformers.should_not be_empty
    stage.notifier_transformers.size.should == 1
    stage.notifier_transformers.first.transformer.should == transformer
  end

  it "should be possible to add a transformer with options to the transformers section of the outbound section of a stage" do
    transformer = :transformer
    options     = {:foo => :bar}

    block = ::Proc.new do
      stage "simple_stage" do
        outbound do
          transformers do
            transformer transformer, options
          end
        end
      end
    end

    stage = ::Blockenspiel.invoke(block, Batsir::DSL::StageMapping.new)
    stage.should_not be_nil
    stage.notifiers.should_not be_nil
    stage.notifiers.should be_empty
    stage.notifier_transformers.should_not be_empty
    stage.notifier_transformers.size.should == 1
    stage.notifier_transformers.first.transformer.should == transformer
    stage.notifier_transformers.first.options.should == options
  end

  it "should be possible to add multiple transformers to the transformers section of the outbound section of a stage" do
    transformer1 = :transformer1
    options     = {:foo => :bar}
    transformer2 = :transformer2

    block = ::Proc.new do
      stage "simple_stage" do
        outbound do
          transformers do
            transformer transformer1, options
            transformer transformer2
          end
        end
      end
    end

    stage = ::Blockenspiel.invoke(block, Batsir::DSL::StageMapping.new)
    stage.should_not be_nil
    stage.notifiers.should_not be_nil
    stage.notifiers.should be_empty
    stage.notifier_transformers.should_not be_empty
    stage.notifier_transformers.size.should == 2
    stage.notifier_transformers.first.transformer.should == transformer1
    stage.notifier_transformers.first.options.should == options
    stage.notifier_transformers.last.transformer.should == transformer2
    stage.notifier_transformers.last.options.should == {}
  end

  it "should be possible to add an outbound section to the stage" do
    notification_class = :notification_class

    block = ::Proc.new do
      stage "simple_stage" do
        outbound do
          notifier notification_class
        end
      end
    end

    stage = ::Blockenspiel.invoke(block, Batsir::DSL::StageMapping.new)
    stage.should_not be_nil
    stage.notifiers.should_not be_empty
    stage.notifiers.should have_key notification_class
    stage.notifiers[notification_class].first.should == {}
  end

  it "should be possible to add an outbound section with a notifier with options to the stage" do
    notification_class = :notification_class
    options = {:queue => :somequeue}

    block = ::Proc.new do
      stage "simple_stage" do
        outbound do
          notifier notification_class, options
        end
      end
    end

    stage = ::Blockenspiel.invoke(block, Batsir::DSL::StageMapping.new)
    stage.should_not be_nil
    stage.notifiers.should_not be_empty
    stage.notifiers.should have_key notification_class
    stage.notifiers[notification_class].first.should == options
  end

  it "should be possible to add multiple notifiers to the stage" do
    notification_class1 = :notification_class1
    options             = {:queue => :somequeue}
    notification_class2 = :notification_class2

    block = ::Proc.new do
      stage "simple_stage" do
        outbound do
          notifier notification_class1, options
          notifier notification_class2
        end
      end
    end

    stage = ::Blockenspiel.invoke(block, Batsir::DSL::StageMapping.new)
    stage.should_not be_nil
    stage.notifiers.should_not be_empty
    stage.notifiers.should have_key notification_class1
    stage.notifiers[notification_class1].first.should == options

    stage.notifiers.should have_key notification_class2
    stage.notifiers[notification_class2].first.should == {}
  end

  it "should be possible to create a complete stage" do
    acceptor_class1     = :acceptor_class1
    options             = {:foo => :bar}
    acceptor_class2     = :acceptor_class2
    stage_name          = "Complete Stage"
    filter1             = "Some Filter"
    filter2             = "Another Filter"
    notification_class1 = :notification_class1
    options             = {:queue => :somequeue}
    notification_class2 = :notification_class2

    block = ::Proc.new do
      stage stage_name do
        inbound do
          acceptor acceptor_class1, options
          acceptor acceptor_class2
        end
        filter filter1
        filter filter2
        outbound do
          notifier notification_class1, options
          notifier notification_class2
        end
      end
    end

    stage = ::Blockenspiel.invoke(block, Batsir::DSL::StageMapping.new)
    stage.should_not be_nil
    stage.name.should == stage_name
    stage.acceptors.should_not be_nil
    stage.acceptors.should_not be_empty
    stage.acceptors.keys.should include acceptor_class1
    stage.acceptors[acceptor_class1].first.should == options
    stage.acceptors.keys.should include acceptor_class2
    stage.acceptors[acceptor_class2].first.should == {}
    stage.filters.should_not be_nil
    stage.filters.should_not be_empty
    stage.filters.should include filter1
    stage.filters.should include filter2
    stage.notifiers.should_not be_nil
    stage.notifiers.should_not be_empty
    stage.notifiers.should have_key notification_class1
    stage.notifiers[notification_class1].first.should == options

    stage.notifiers.should have_key notification_class2
    stage.notifiers[notification_class2].first.should == {}
  end
end
