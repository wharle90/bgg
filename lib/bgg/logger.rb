require 'singleton'
require 'logger'

module Bgg
  class Logger
    LOG_METHODS = %i(info debug fatal warn error level)

    include Singleton
    extend Forwardable

    attr_reader :logger
    def_delegators :logger, *LOG_METHODS

    def initialize
      @logger = ::Logger.new($stdout)
      @logger.level = if ENV['LOG_LEVEL']
                        ::Logger.const_get(ENV['LOG_LEVEL'].upcase)
                      else
                        ::Logger::INFO
                      end
    end

    class << self
      extend Forwardable

      def_delegators :instance, *LOG_METHODS
    end
  end
end
