require 'singleton'
require 'yaml'
require 'fileutils'

module Bgg
  class Cache
    include Singleton

    class << self
      extend Forwardable
      def_delegators :instance, :[], :[]=
    end

    FILE = '.bgg/cache.yml'

    def initialize
      if File.exists?(FILE)
        Bgg::Logger.debug "Cache file #{FILE} found, loading from cache"
        @cache = YAML.load_file(FILE)
      else
        Bgg::Logger.debug "No cache file found, initializing fresh cache"
        @cache = {}
      end

      at_exit { persist! }
    end

    def persist!
      Bgg::Logger.debug "Persisting cache to #{FILE}"
      FileUtils.mkdir_p File.dirname(FILE)
      YAML.dump(@cache, File.open(FILE, 'w'))
    end

    def []=(request, response)
      @cache[request] = response
    end

    def [](request)
      @cache[request]
    end

    module Middleware
      Mock = Struct.new(:code, :body)

      def get(*args)
        return Mock.new(200, Bgg::Cache[args]) if Bgg::Cache[args]
        response = super *args
        Bgg::Cache[args] = response.body if (200..299) === response.code
        response
      end
    end
  end
end
