require File.join( File.dirname(__FILE__), "..", "spec_helper" )

describe Batsir::Config do
  context "with respect to retrieving variables" do
    it "can check if a key exists" do
      Batsir::Config.key?(:sidekiq_queue).should be_true
      Batsir::Config.key?(:non_existent).should be_false
    end

    it "can use brackets" do
      Batsir::Config[:sidekiq_queue].should == 'batsir'
    end

    it "can use fetch method" do
      Batsir::Config.fetch(:sidekiq_queue, nil).should == 'batsir'
    end

    it "returns the default value when variable does not exist" do
      Batsir::Config.fetch(:dbase, 'default').should == 'default'
    end

    it "can use a method with the variable's name" do
      Batsir::Config.sidekiq_queue.should == 'batsir'
    end

    it "can use return the settings in a hash" do
      Batsir::Config[:dbase] = :test
      hash = Batsir::Config.to_hash
      hash.keys.include?(:sidekiq_queue).should be_true
      hash.keys.include?(:dbase).should be_true
      hash.values.include?(:test).should be_true
      hash.values.include?('batsir').should be_true
    end
  end

  context "with respect to setting variables" do
    it "can set a variable using brackets" do
      Batsir::Config[:testtest] = "testtest"
      Batsir::Config.testtest.should == "testtest"
    end

    it "can set a variable using a method with the variable's name" do
      Batsir::Config.testtest = "test1"
      Batsir::Config[:testtest].should == "test1"
    end

    context "setting multiple variables at once" do
      it "can use setup method" do
        Batsir::Config.setup({:test_var => "test1", :test_var2 => "test2"})
        Batsir::Config.test_var.should == "test1"
        Batsir::Config.test_var2.should == "test2"
      end

      it "merges given settings with default settings when using setup method" do
        Batsir::Config.setup({:test_var => "test1", :test_var2 => "test2"})
        Batsir::Config.sidekiq_queue.should == 'batsir'
      end

      context "with block notation" do
        it "uses yielding" do
          Batsir::Config.use do |config|
            config[:tester1] = "test1"
            config[:tester2] = "test2"
          end
          Batsir::Config.sidekiq_queue.should == 'batsir'
          Batsir::Config.tester1.should == "test1"
          Batsir::Config.tester2.should == "test2"
        end

        it "uses a block" do
          Batsir::Config.configure do
            tester3 "test3"
            tester4 "test4"
          end
          Batsir::Config.sidekiq_queue.should == 'batsir'
          Batsir::Config.tester3.should == "test3"
          Batsir::Config.tester4.should == "test4"
        end
      end
    end
  end

  context "with respect to deleting variables" do
    it "deletes the given key" do
      Batsir::Config.sidekiq_queue.should_not be_nil
      Batsir::Config.delete(:sidekiq_queue)
      Batsir::Config.sidekiq_queue.should be_nil
    end
  end
end

describe Batsir::Config, "with respect to resetting the configuration" do

  it "resets properly" do
    Batsir::Config.reset
    Batsir::Config.to_hash.should_not be_nil
  end
end
