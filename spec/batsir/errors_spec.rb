require File.join( File.dirname(__FILE__), "..", "spec_helper" )

describe Batsir::Errors do

  it "defines all Batsir-specific error classes" do
    Batsir::Errors::BatsirError.new.should be_a RuntimeError
    Batsir::Errors::NotifierError.new.should be_a Batsir::Errors::BatsirError
    Batsir::Errors::TransformError.new.should be_a Batsir::Errors::BatsirError

    Batsir::Errors::ExecuteMethodNotImplementedError.new.should be_a Batsir::Errors::BatsirError

    Batsir::Errors::NotifierConnectionError.new.should be_a Batsir::Errors::NotifierError

    Batsir::Errors::JSONInputTransformError.new.should be_a Batsir::Errors::TransformError
    Batsir::Errors::JSONOutputTransformError.new.should be_a Batsir::Errors::TransformError
  end
end

