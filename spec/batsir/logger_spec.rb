require File.join( File.dirname(__FILE__), "..", "spec_helper" )

describe Batsir::Logger do
  before :all do
    @logger = Batsir::Logger
  end

  it 'returns an object of Log4r::Logger class' do
    @logger.log.should be_a Log4r::Logger
  end

  it 'allows changing its settings' do
    @logger.level.should_not == Log4r::DEBUG
    @logger.level = Log4r::DEBUG
    @logger.level.should == Log4r::DEBUG
  end

  it 'can be reset' do
    current_log = @logger.level
    Batsir::Logger.reset
    @logger.level.should_not == current_log
  end

  it 'is able to use various log levels' do
    @logger.level = Log4r::DEBUG
    debug = @logger.debug("debug test message")
    debug.should be_an Array
    debug.select{|e| e.is_a?(Log4r::StdoutOutputter)}.should_not be_empty

    info = @logger.info("info test message")
    info.should be_an Array
    info.select{|e| e.is_a?(Log4r::StdoutOutputter)}.should_not be_empty

    warn = @logger.warn("warning test message")
    warn.should be_an Array
    warn.select{|e| e.is_a?(Log4r::StdoutOutputter)}.should_not be_empty

    err = @logger.error("error test message")
    err.should be_an Array
    err.select{|e| e.is_a?(Log4r::StdoutOutputter)}.should_not be_empty

    fatal = @logger.fatal("fatal test message")
    fatal.should be_an Array
    fatal.select{|e| e.is_a?(Log4r::StdoutOutputter)}.should_not be_empty
  end
end
