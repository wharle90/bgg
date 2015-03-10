module Bgg
  module Request
    class User < Base

      DOMAIN_BOARDGAME = { domain: 'boardgame' }
      DOMAIN_RPG = { domain: 'rpg' }
      DOMAIN_VIDEOGAME = { domain: 'videogame' }
      ALL_FIELDS = { buddies: 1, guilds: 1, hot: 1, top: 1 }

      def self.list_board_games(username, params = {})
        Bgg::Request::User.new username, params.merge!(DOMAIN_BOARDGAME).merge!(ALL_FIELDS)
      end

      def self.list_rpgs(username, params = {})
        Bgg::Request::User.new username, params.merge!(DOMAIN_RPG).merge!(ALL_FIELDS)
      end

      def self.list_video_games(username, params = {})
        Bgg::Request::User.new username, params.merge!(DOMAIN_VIDEOGAME).merge!(ALL_FIELDS)
      end

      def initialize(username, params = {})
        if invalid_username username
          raise ArgumentError.new 'missing required username'
        else
          params[:name] = username
        end

        super :user, params
      end

      def all_fields
        @params.merge!(ALL_FIELDS)
        self
      end

      def page(num)
        @params.merge!( { page: num })
        self
      end
    end
  end
end
