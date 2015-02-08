module Bgg
  module Request
    class Family < Base
      def initialize(id, params = {})
        if invalid_id(id)
          raise ArgumentError.new 'missing required argument'
        else
          params[:id] = id
        end
        super :family, params
      end
    end
  end
end
