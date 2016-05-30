require 'bgg/logger'

module Bgg
  module Request
    module BackoffStrategy
      def self.next(backoff = nil)
        2 * (backoff || 2)
      end

      module Middleware
        def get(url, params = {})
          last_backoff = params.delete(:last_backoff)

          begin
            response = super url, params

            if response.code == 503
              backoff = Bgg::Request::BackoffStrategy.next(last_backoff)
              Logger.debug "Rate limited, sleeping for #{backoff} seconds"
              sleep backoff
              params.merge!(last_backoff: backoff)
              response = get(url, params)
            end

            response
          end
        end
      end
    end
  end
end
