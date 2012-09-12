require File.join( File.dirname(__FILE__), "..", "spec_helper" )

describe Batsir::Logger do
  before :all do
    @logger = Batsir::Logger
  end

  it 'returns an object of Log4r::Logger class' do
    @logger.log.should be_a Log4r::Logger
  end

  it 'allows changing its settings' do
    @logger.log.level.should == Log4r::WARN
    @logger.log.level = Log4r::DEBUG
    @logger.log.level.should == Log4r::DEBUG
  end

  it 'can be reset' do
    @logger.log.level.should == Log4r::DEBUG
    Batsir::Logger.reset
    @logger.log.level.should == Log4r::WARN
  end

  it 'is able to use various log levels' do
    @logger.log.level = Log4r::DEBUG
    debug = @logger.log.debug("debug test message")
    debug.should be_an Array
    debug.select{|e| e.is_a?(Log4r::StdoutOutputter)}.should_not be_empty

    info = @logger.log.info("info test message")
    info.should be_an Array
    info.select{|e| e.is_a?(Log4r::StdoutOutputter)}.should_not be_empty

    warn = @logger.log.warn("warning test message")
    warn.should be_an Array
    warn.select{|e| e.is_a?(Log4r::StdoutOutputter)}.should_not be_empty

    err = @logger.log.error("error test message")
    err.should be_an Array
    err.select{|e| e.is_a?(Log4r::StdoutOutputter)}.should_not be_empty

    fatal = @logger.log.fatal("fatal test message")
    fatal.should be_an Array
    fatal.select{|e| e.is_a?(Log4r::StdoutOutputter)}.should_not be_empty
  end
end
