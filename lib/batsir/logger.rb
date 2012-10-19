require 'log4r'

module Batsir
  module Logger
    DEBUG  = 1
    INFO   = 2
    WARN   = 3
    ERROR  = 4
    SEVERE = 5

    class << self

      DEFAULT_OUTPUT = 'stdout'

      def log
        @logger ||= setup
      end

      def setup
        logger = Log4r::Logger.new(Batsir::Config.fetch(:log_name, "batsir"))
        logger.level      = Batsir::Config.fetch(:log_level, WARN)
        logger.outputters = Batsir::Config.fetch(:log_outputter, DEFAULT_OUTPUT)
        logger
      end

      def reset
        @logger = nil
      end

      # makes this respond like a Log4r::Logger
      def method_missing(sym, *args, &block)
        log.send sym, *args, &block
      end

    end
  end
end
