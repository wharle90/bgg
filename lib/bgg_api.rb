require 'httparty'
require 'xmlsimple'
require 'bgg/request/backoff_strategy'
require 'bgg/cache'

class BggApi
  include HTTParty
  extend Bgg::Request::BackoffStrategy::Middleware
  extend Bgg::Cache::Middleware

  OLD_METHODS = [
    :forum,
    :forumlist,
    :thing,
    :thread
  ].freeze

  NEW_METHODS = [
    :collection,
    :family,
    :guild,
    :hot,
    :plays,
    :search,
    :user
  ].freeze

  BASE_URI = 'https://www.boardgamegeek.com/xmlapi2'

  OLD_METHODS.each do |method|
    define_singleton_method(method) do |params = {}|
      url = BASE_URI + '/' + method.to_s
      response = self.get(url, :query => params)

      case response.code
      when (200..299)
        xml_data = response.body
        XmlSimple.xml_in(xml_data)
      else
        raise "Received a #{response.code} at #{url} with #{params}"
      end
    end
  end

  NEW_METHODS.each do |method|
    define_singleton_method method do |*params|
      request = Object.const_get('Bgg').const_get('Request').const_get(method.to_s.capitalize).new *params
      request.get
    end
  end
end


require 'bgg/request/base'
require 'bgg/request/collection'
require 'bgg/request/family'
require 'bgg/request/guild'
require 'bgg/request/hot'
require 'bgg/request/plays'
require 'bgg/request/search'
require 'bgg/request/user'
require 'bgg/request/backoff_strategy'

require 'bgg/result/item'
require 'bgg/result/enumerable'
require 'bgg/result/collection'
require 'bgg/result/collection_item'
require 'bgg/result/collection_item_rank'
require 'bgg/result/family'
require 'bgg/result/guild'
require 'bgg/result/hot'
require 'bgg/result/hot_item'
require 'bgg/result/plays'
require 'bgg/result/plays_play'
require 'bgg/result/search'
require 'bgg/result/search_item'
require 'bgg/result/user'

require 'bgg/game'
require 'bgg/logger'
require 'bgg/cache'
