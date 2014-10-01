require File.join( File.dirname(__FILE__), "..", "spec_helper" )

describe Batsir::Logger do
  before :all do
    @logger = Batsir::Logger
  end

  it 'returns an object of Log4r::Logger class' do
    expect(@logger.log).to be_a Log4r::Logger
  end

  it 'allows changing its settings' do
    expect(@logger.level).not_to eq(Log4r::DEBUG)
    @logger.level = Log4r::DEBUG
    expect(@logger.level).to eq(Log4r::DEBUG)
  end

  it 'can be reset' do
    current_log = @logger.level
    Batsir::Logger.reset
    expect(@logger.level).not_to eq(current_log)
  end

  it 'is able to use various log levels' do
    @logger.level = Log4r::DEBUG
    debug = @logger.debug("debug test message")
    expect(debug).to be_an Array
    expect(debug.select{|e| e.is_a?(Log4r::StdoutOutputter)}).not_to be_empty

    info = @logger.info("info test message")
    expect(info).to be_an Array
    expect(info.select{|e| e.is_a?(Log4r::StdoutOutputter)}).not_to be_empty

    warn = @logger.warn("warning test message")
    expect(warn).to be_an Array
    expect(warn.select{|e| e.is_a?(Log4r::StdoutOutputter)}).not_to be_empty

    err = @logger.error("error test message")
    expect(err).to be_an Array
    expect(err.select{|e| e.is_a?(Log4r::StdoutOutputter)}).not_to be_empty

    fatal = @logger.fatal("fatal test message")
    expect(fatal).to be_an Array
    expect(fatal.select{|e| e.is_a?(Log4r::StdoutOutputter)}).not_to be_empty
  end
end
