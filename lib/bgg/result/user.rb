module Bgg
  module Result
    class User < Item
      extend Forwardable

      attr_reader :avatar_link, :battle_net_account, :buddy_count,
                  :buddy_page, :country, :first_name, :guild_count,
                  :guild_page, :id, :last_login, :last_name,
                  :psn_account, :state, :steam_account,
                  :trade_rating, :username, :year_registered,
                  :web_address, :wii_account, :xbox_account

      def initialize(item, request)
        super item, request

        @id = xpath_value_int('user/@id')
        raise ArgumentError.new('User does not exist') if id.nil?

        @avatar_link = xpath_value('user/avatarlink/@value')
        @battle_net_account = xpath_value('user/battlenetaccount/@value')
        @buddy_count = xpath_value_int('user/buddies/@total')
        @buddy_page = xpath_value_int('user/buddies/@page')
        @country = xpath_value('user/country/@value')
        @first_name = xpath_value('user/firstname/@value')
        @guild_count = xpath_value_int('user/guilds/@total')
        @guild_page = xpath_value_int('user/guilds/@page')
        @last_login = xpath_value_date('user/lastlogin/@value')
        @last_name = xpath_value('user/lastname/@value')
        @psn_account = xpath_value('user/psnaccount/@value')
        @state = xpath_value('user/stateorprovince/@value')
        @steam_account = xpath_value('user/steamaccount/@value')
        @trade_rating = xpath_value_int('user/traderating/@value')
        @username = request_params[:name]
        @year_registered = xpath_value_int('user/yearregistered/@value')
        @web_address = xpath_value('user/webaddress/@value')
        @wii_account = xpath_value('user/wiiaccount/@value')
        @xbox_account = xpath_value('user/xboxaccount/@value')
      end

      def buddies
        @buddies ||= @xml.xpath('user/buddies/buddy').map do |buddy|
          xpath_value('@name', buddy)
        end
      end

      def guilds
        @guilds ||= @xml.xpath('user/guilds/guild').map do |guild|
          { id: xpath_value_int('@id', guild), name: xpath_value('@name', guild) }
        end
      end

      def guild_names
        guilds.map { |guild| guild[:name] }
      end

      def hot
        @hot ||= list('user/hot/item')
      end

      def top
        @top ||= list('user/top/item')
      end

      def plays
        @plays ||= BggApi.plays username, nil
      end

      def collection
        @collection ||= BggApi.collection username
      end

      private

      def list(path)
        @xml.xpath(path).map do |item|
          {
            id: xpath_value_int('@id', item),
            name: xpath_value('@name', item),
            type: xpath_value('@type', item),
            rank: xpath_value_int('@rank', item),
          }
        end
      end
    end
  end
end
