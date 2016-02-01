require 'logger'
require 'pra/config'
require 'date'

module Pra
  class Log
    def self.logger
      @logger ||= begin 
        logger = Logger.new(Pra::Config.log_path, 10, 5000000)
        logger.formatter = proc { |severity, datetime, progname, msg|
          "#{datetime.iso8601} #{severity} - #{msg}\n"
        }
        logger.level = Logger::INFO
        logger
      end
    end

    def self.level(level)
      logger.level = Logger.const_get level.upcase
    end

    def self.info(message)
      logger.info(message)
    end

    def self.debug(message)
      logger.debug(message)
    end
    
    def self.error(message)
      logger.error(message)
      if message.responds_to?(:backtrace)
        message.backtrace.each { |line| logger.error(line) }
      end
    end
  end
end
