module Bgg
  module Result
    class Family < Item
      attr_reader :description, :id, :image, :name, :thumbnail, :type

      def initialize(item, request)
        super item, request

        raise ArgumentError.new('User does not exist') if xpath_value('items/item').nil?

        @description = xpath_value('items/item/description')
        @id = request_params[:id]
        @image = xpath_value('items/item/image')
        @name = xpath_value('items/item/name/@value')
        @thumbnail = xpath_value('items/item/thumbnail')
        @type = xpath_value('items/item/@type')
      end

      def items
        @items ||= @xml.xpath('items/item/link').map do |item|
          { id: xpath_value_int('@id', item), name: xpath_value('@value', item) }
        end
      end
    end
  end
end
