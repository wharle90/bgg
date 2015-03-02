module Bgg
  module Result
    class Guild < Item
      attr_reader :address, :category, :city, :country, :created,
                  :description, :id, :manager, :member_count, :member_page,
                  :name, :postal_code, :state, :website

      def initialize(item, request)
        super item, request

        addr1 = xpath_value('guild/location/addr1')
        addr2 = xpath_value('guild/location/addr2')
        @address = "#{addr1} #{addr2}" if(addr1 || addr2)
        @category = xpath_value('guild/category')
        @city = xpath_value('guild/location/city')
        @country = xpath_value('guild/location/country')
        @created = xpath_value_time('guild/@created')
        @description = xpath_value('guild/description')
        @id = request_params[:id]
        @manager = xpath_value('guild/manager')
        @member_count = xpath_value_int('guild/members/@count')
        @member_page = xpath_value_int('guild/members/@page')
        @name = xpath_value('guild/@name')
        @postal_code = xpath_value('guild/location/postalcode')
        @state = xpath_value('guild/location/stateorprovince')
        @website = xpath_value('guild/website')
      end

      def member_usernames
        members.map { |member| member[:name] }
      end

      def members
        @members ||= @xml.xpath('guild/members/member').map do |member|
          { name: xpath_value('@name', member), date: xpath_value_time('@date', member) }
        end
      end
    end
  end
end
