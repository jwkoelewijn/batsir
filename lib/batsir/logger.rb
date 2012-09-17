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
        log = Log4r::Logger.new(Batsir::Config.fetch(:log_name, "batsir"))
        log.level      = Batsir::Config.fetch(:log_level, WARN)
        log.outputters = Batsir::Config.fetch(:log_outputter, DEFAULT_OUTPUT)
        log
      end

      def reset
        @logger = nil
      end

    end
  end
end
