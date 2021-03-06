require 'httparty'
require 'nokogiri'
require 'bgg/request/backoff_strategy'
require 'bgg/cache'

module Bgg
  module Request
    class Base
      include HTTParty
      extend Bgg::Request::BackoffStrategy::Middleware
      extend Bgg::Cache::Middleware

      attr_reader :params

      METHODS = [
        :collection,
        :family,
        :forum,
        :forumlist,
        :guild,
        :hot,
        :plays,
        :search,
        :thing,
        :thread,
        :user
      ].freeze

      BASE_URI = 'https://www.boardgamegeek.com/xmlapi2'

      def initialize(method, params = {})
        raise ArgumentError.new 'unknown request method' unless METHODS.include? method

        @method = method
        @params = params
      end

      def get
        url = BASE_URI + '/' + @method.to_s
        response = self.class.get url, query: @params

        case response.code
        when (200..299)
          xml_result = Nokogiri.XML response.body
          Object.const_get("Bgg").const_get("Result").const_get(@method.to_s.capitalize).new xml_result, self
        else
          raise "Received a #{response.code} at #{url} with #{@params}"
        end
      end

      def add_params(params)
        @params.merge! params
      end

      protected

      def invalid_username(username)
        username.nil? || username.empty?
      end

      def invalid_id(id)
        id.nil? || !id.kind_of?(Integer)
      end
    end
  end
end
