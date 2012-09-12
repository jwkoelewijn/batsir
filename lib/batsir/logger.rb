require 'log4r'

module Batsir
  module Logger
    class << self

      DEFAULT_OUTPUT = 'stdout'

      def log
        @logger ||= setup
      end

      def setup
        settings = Batsir::Config.log.clone
        log = Log4r::Logger.new(settings.fetch(:name))
        log.level      = settings.fetch(:level, Log4r::WARN)
        log.outputters = settings.fetch(:output, DEFAULT_OUTPUT)
        log
      end

      def reset
        @logger = nil
      end

    end
  end
end

