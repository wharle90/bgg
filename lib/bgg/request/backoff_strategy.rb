require 'bgg/logger'

module Bgg
  module Request
    module BackoffStrategy
      def self.next(backoff = nil)
        next_backoff = 2 * (backoff || 0.1)
        Logger.debug("Next backoff: #{next_backoff}")
        next_backoff
      end
    end
  end
end
