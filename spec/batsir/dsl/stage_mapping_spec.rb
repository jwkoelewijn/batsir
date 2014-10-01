require File.join( File.dirname(__FILE__), "..", "..", "spec_helper")

describe Batsir::DSL::StageMapping do
  it "creates a simple stage with a name" do
    block = ::Proc.new do
      stage "simple_stage" do
      end
    end

    stage = ::Blockenspiel.invoke(block, Batsir::DSL::StageMapping.new)
    expect(stage).not_to be_nil
    expect(stage.name).to eq("simple_stage")
  end

  it "can add a filter to the stage" do
    filter = "Operation"

    block = ::Proc.new do
      stage "simple_stage" do
        filter filter
      end
    end

    stage = ::Blockenspiel.invoke(block, Batsir::DSL::StageMapping.new)
    expect(stage).not_to be_nil
    expect(stage.filters).not_to be_nil
    expect(stage.filters).not_to be_empty
    expect(stage.filters).to include filter
  end

  it "can add a filter with options to the stage" do
    filter  = "Operation"
    options = { :option => "options" }

    block = ::Proc.new do
      stage "simple_stage" do
        filter filter, options
      end
    end

    stage = ::Blockenspiel.invoke(block, Batsir::DSL::StageMapping.new)
    expect(stage).not_to be_nil
    expect(stage.filters).not_to be_nil
    expect(stage.filters).not_to be_empty
    declaration = stage.filter_declarations.find{|decl| decl.filter == filter }
    expect(declaration.options).to eq(options)
  end

  it "can add multiple filters to the stage" do
    filter1 = "Operation 1"
    filter2 = "Operation 2"

    block = ::Proc.new do
      stage "simple_stage" do
        filter filter1
        filter filter2
      end
    end

    stage = ::Blockenspiel.invoke(block, Batsir::DSL::StageMapping.new)
    expect(stage).not_to be_nil
    expect(stage.filters).not_to be_nil
    expect(stage.filters).not_to be_empty
    expect(stage.filters).to include filter1
    expect(stage.filters).to include filter2
  end

  it "can add an inbound section to a stage" do
    block = ::Proc.new do
      stage "simple_stage" do
        inbound do

        end
      end
    end

    stage = ::Blockenspiel.invoke(block, Batsir::DSL::StageMapping.new)
    expect(stage).not_to be_nil
    expect(stage.acceptors).not_to be_nil
    expect(stage.acceptors).to be_empty
  end

  it "can add a transformers section to the inbound section of a stage" do
    block = ::Proc.new do
      stage "simple_stage" do
        inbound do
          transformers do

          end
        end
      end
    end

    stage = ::Blockenspiel.invoke(block, Batsir::DSL::StageMapping.new)
    expect(stage).not_to be_nil
    expect(stage.acceptors).not_to be_nil
    expect(stage.acceptors).to be_empty
    expect(stage.acceptor_transformers).to be_empty
  end

  it "can add a transformer to the transformers section of the inbound section of a stage" do
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
    expect(stage).not_to be_nil
    expect(stage.acceptors).not_to be_nil
    expect(stage.acceptors).to be_empty
    expect(stage.acceptor_transformers).not_to be_empty
    expect(stage.acceptor_transformers.size).to eq(1)
    expect(stage.acceptor_transformers.first.transformer).to eq(transformer)
  end

  it "can add a transformer with options to the transformers section of the inbound section of a stage" do
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
    expect(stage).not_to be_nil
    expect(stage.acceptors).not_to be_nil
    expect(stage.acceptors).to be_empty
    expect(stage.acceptor_transformers).not_to be_empty
    expect(stage.acceptor_transformers.size).to eq(1)
    expect(stage.acceptor_transformers.first.transformer).to eq(transformer)
    expect(stage.acceptor_transformers.first.options).to eq(options)
  end

  it "can add multiple transformers to the transformers section of the inbound section of a stage" do
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
    expect(stage).not_to be_nil
    expect(stage.acceptors).not_to be_nil
    expect(stage.acceptors).to be_empty
    expect(stage.acceptor_transformers).not_to be_empty
    expect(stage.acceptor_transformers.size).to eq(2)
    expect(stage.acceptor_transformers.first.transformer).to eq(transformer1)
    expect(stage.acceptor_transformers.first.options).to eq(options)
    expect(stage.acceptor_transformers.last.transformer).to eq(transformer2)
    expect(stage.acceptor_transformers.last.options).to eq({})
  end

  it "can add an acceptor to a stage" do
    acceptor_class = :acceptor_class

    block = ::Proc.new do
      stage "simple_stage" do
        inbound do
          acceptor acceptor_class
        end
      end
    end

    stage = ::Blockenspiel.invoke(block, Batsir::DSL::StageMapping.new)
    expect(stage).not_to be_nil
    expect(stage.acceptors).not_to be_nil
    expect(stage.acceptors).not_to be_empty
    expect(stage.acceptors.keys).to include acceptor_class
    expect(stage.acceptors[acceptor_class].first).to eq({})
  end

  it "can add an inbound section with an acceptor with options to the stage" do
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
    expect(stage).not_to be_nil
    expect(stage.acceptors).not_to be_nil
    expect(stage.acceptors).not_to be_empty
    expect(stage.acceptors.keys).to include acceptor_class
    expect(stage.acceptors[acceptor_class].first).to eq(options)
  end

  it "can add multiple acceptors to a stage" do
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
    expect(stage).not_to be_nil
    expect(stage.acceptors).not_to be_nil
    expect(stage.acceptors).not_to be_empty
    expect(stage.acceptors.keys).to include acceptor_class1
    expect(stage.acceptors[acceptor_class1].first).to eq(options)
    expect(stage.acceptors.keys).to include acceptor_class2
    expect(stage.acceptors[acceptor_class2].first).to eq({})
  end

  it "can add an outbound section without any notifiers" do
    block = ::Proc.new do
      stage "simple_stage" do
        outbound do

        end
      end
    end

    stage = ::Blockenspiel.invoke(block, Batsir::DSL::StageMapping.new)
    expect(stage).not_to be_nil
    expect(stage.notifiers).not_to be_nil
    expect(stage.notifiers).to be_empty
  end

  it "can add a transformers section to the outbound section of a stage" do
    block = ::Proc.new do
      stage "simple_stage" do
        outbound do
          transformers do

          end
        end
      end
    end

    stage = ::Blockenspiel.invoke(block, Batsir::DSL::StageMapping.new)
    expect(stage).not_to be_nil
    expect(stage.notifiers).not_to be_nil
    expect(stage.notifiers).to be_empty
    expect(stage.notifier_transformers).to be_empty
  end

  it "can add a transformer to the transformers section of the outbound section of a stage" do
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
    expect(stage).not_to be_nil
    expect(stage.notifiers).not_to be_nil
    expect(stage.notifiers).to be_empty
    expect(stage.notifier_transformers).not_to be_empty
    expect(stage.notifier_transformers.size).to eq(1)
    expect(stage.notifier_transformers.first.transformer).to eq(transformer)
  end

  it "can add a transformer with options to the transformers section of the outbound section of a stage" do
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
    expect(stage).not_to be_nil
    expect(stage.notifiers).not_to be_nil
    expect(stage.notifiers).to be_empty
    expect(stage.notifier_transformers).not_to be_empty
    expect(stage.notifier_transformers.size).to eq(1)
    expect(stage.notifier_transformers.first.transformer).to eq(transformer)
    expect(stage.notifier_transformers.first.options).to eq(options)
  end

  it "can add multiple transformers to the transformers section of the outbound section of a stage" do
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
    expect(stage).not_to be_nil
    expect(stage.notifiers).not_to be_nil
    expect(stage.notifiers).to be_empty
    expect(stage.notifier_transformers).not_to be_empty
    expect(stage.notifier_transformers.size).to eq(2)
    expect(stage.notifier_transformers.first.transformer).to eq(transformer1)
    expect(stage.notifier_transformers.first.options).to eq(options)
    expect(stage.notifier_transformers.last.transformer).to eq(transformer2)
    expect(stage.notifier_transformers.last.options).to eq({})
  end

  it "can add an outbound section to the stage" do
    notification_class = :notification_class

    block = ::Proc.new do
      stage "simple_stage" do
        outbound do
          notifier notification_class
        end
      end
    end

    stage = ::Blockenspiel.invoke(block, Batsir::DSL::StageMapping.new)
    expect(stage).not_to be_nil
    expect(stage.notifiers).not_to be_empty
    expect(stage.notifiers).to have_key notification_class
    expect(stage.notifiers[notification_class].first).to eq({})
  end

  it "can add an outbound section with a notifier with options to the stage" do
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
    expect(stage).not_to be_nil
    expect(stage.notifiers).not_to be_empty
    expect(stage.notifiers).to have_key notification_class
    expect(stage.notifiers[notification_class].first).to eq(options)
  end

  it "can add multiple notifiers to the stage" do
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
    expect(stage).not_to be_nil
    expect(stage.notifiers).not_to be_empty
    expect(stage.notifiers).to have_key notification_class1
    expect(stage.notifiers[notification_class1].first).to eq(options)

    expect(stage.notifiers).to have_key notification_class2
    expect(stage.notifiers[notification_class2].first).to eq({})
  end

  it "can create a complete stage" do
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
    expect(stage).not_to be_nil
    expect(stage.name).to eq(stage_name)
    expect(stage.acceptors).not_to be_nil
    expect(stage.acceptors).not_to be_empty
    expect(stage.acceptors.keys).to include acceptor_class1
    expect(stage.acceptors[acceptor_class1].first).to eq(options)
    expect(stage.acceptors.keys).to include acceptor_class2
    expect(stage.acceptors[acceptor_class2].first).to eq({})
    expect(stage.filters).not_to be_nil
    expect(stage.filters).not_to be_empty
    expect(stage.filters).to include filter1
    expect(stage.filters).to include filter2
    expect(stage.notifiers).not_to be_nil
    expect(stage.notifiers).not_to be_empty
    expect(stage.notifiers).to have_key notification_class1
    expect(stage.notifiers[notification_class1].first).to eq(options)

    expect(stage.notifiers).to have_key notification_class2
    expect(stage.notifiers[notification_class2].first).to eq({})
  end
end
