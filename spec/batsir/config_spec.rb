require File.join( File.dirname(__FILE__), "..", "spec_helper" )

describe Batsir::Config do
  context "with respect to retrieving variables" do
    it "can check if a key exists" do
      expect(Batsir::Config.key?(:sidekiq_queue)).to be_truthy
      expect(Batsir::Config.key?(:non_existent)).to be_falsey
    end

    it "can use brackets" do
      expect(Batsir::Config[:sidekiq_queue]).to eq('batsir')
    end

    it "can use fetch method" do
      expect(Batsir::Config.fetch(:sidekiq_queue, nil)).to eq('batsir')
    end

    it "returns the default value when variable does not exist" do
      expect(Batsir::Config.fetch(:dbase, 'default')).to eq('default')
    end

    it "can use a method with the variable's name" do
      expect(Batsir::Config.sidekiq_queue).to eq('batsir')
    end

    it "can use return the settings in a hash" do
      Batsir::Config[:dbase] = :test
      hash = Batsir::Config.to_hash
      expect(hash.keys.include?(:sidekiq_queue)).to be_truthy
      expect(hash.keys.include?(:dbase)).to be_truthy
      expect(hash.values.include?(:test)).to be_truthy
      expect(hash.values.include?('batsir')).to be_truthy
    end
  end

  context "with respect to setting variables" do
    it "can set a variable using brackets" do
      Batsir::Config[:testtest] = "testtest"
      expect(Batsir::Config.testtest).to eq("testtest")
    end

    it "can set a variable using a method with the variable's name" do
      Batsir::Config.testtest = "test1"
      expect(Batsir::Config[:testtest]).to eq("test1")
    end

    context "setting multiple variables at once" do
      it "can use setup method" do
        Batsir::Config.setup({:test_var => "test1", :test_var2 => "test2"})
        expect(Batsir::Config.test_var).to eq("test1")
        expect(Batsir::Config.test_var2).to eq("test2")
      end

      it "merges given settings with default settings when using setup method" do
        Batsir::Config.setup({:test_var => "test1", :test_var2 => "test2"})
        expect(Batsir::Config.sidekiq_queue).to eq('batsir')
      end

      context "with block notation" do
        it "uses yielding" do
          Batsir::Config.use do |config|
            config[:tester1] = "test1"
            config[:tester2] = "test2"
          end
          expect(Batsir::Config.sidekiq_queue).to eq('batsir')
          expect(Batsir::Config.tester1).to eq("test1")
          expect(Batsir::Config.tester2).to eq("test2")
        end

        it "uses a block" do
          Batsir::Config.configure do
            tester3 "test3"
            tester4 "test4"
          end
          expect(Batsir::Config.sidekiq_queue).to eq('batsir')
          expect(Batsir::Config.tester3).to eq("test3")
          expect(Batsir::Config.tester4).to eq("test4")
        end
      end
    end
  end

  context "with respect to deleting variables" do
    it "deletes the given key" do
      expect(Batsir::Config.sidekiq_queue).not_to be_nil
      Batsir::Config.delete(:sidekiq_queue)
      expect(Batsir::Config.sidekiq_queue).to be_nil
    end
  end
end

describe Batsir::Config, "with respect to resetting the configuration" do
  it "resets properly" do
    Batsir::Config.reset
    expect(Batsir::Config.to_hash).to eq(Batsir::Config.defaults)
  end
end
