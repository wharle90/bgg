module Bgg
  module Result
    class Collection
      class Item < Item

        attr_reader :average_rating, :bgg_rating, :collection_id, :comment,
                    :id, :image, :last_modified, :name, :own_count, :play_count,
                    :play_time, :players, :thumbnail, :theme_ranks, :type,
                    :type_rank, :user_rating, :year_published

        def initialize(item, request)
          super item, request
          set_attributes
        end

        def for_trade?
          @for_trade
        end

        def owned?
          @owned
        end

        def played?
          @play_count > 0 unless @play_count.nil?
        end

        def preordered?
          @preordered
        end

        def published?
          unless @year_published.nil?
            @year_published != 0 and @year_published <= Time.now.year
          end
        end

        def wanted?
          @wanted
        end

        def want_to_buy?
          @want_to_buy
        end

        def want_to_play?
          @want_to_play
        end

        def perfect?;   @user_rating >= 10; end
        def favorite?;  @user_rating >= 9;  end
        def great?;     @user_rating >= 8;  end
        def good?;      @user_rating >= 7;  end
        def okay?;      @user_rating >= 6;  end
        def bad?;       @user_rating <= 6;  end

        %i(josh lauren).each do |person|
          eval <<-EOF
            def #{person}_rated?
              return false if comment.nil?
              !!comment[/(?<=#{person.capitalize} )\\d[^\\/]*/]
            end

            def #{person}_rating
              comment[/(?<=#{person.capitalize} )\\d[^\\/]*/].to_f * 2
            end

            def #{person}_perfect?;   #{person}_rating >= 10; end
            def #{person}_favorite?;  #{person}_rating >= 9;  end
            def #{person}_great?;     #{person}_rating >= 8;  end
            def #{person}_good?;      #{person}_rating >= 7;  end
            def #{person}_okay?;      #{person}_rating >= 6;  end
            def #{person}_bad?;       #{person}_rating <= 6;  end
          EOF
        end

        def rated?
          !!@user_rating
        end

        def unplayed?
          !rated?
        end

        def game
          @game
        end

        def game=(g)
          @game = g
        end

        def inspect
          ENV['SHORT_INSPECT'] ? "\"#{@name}\"" : super
        end

        def method_missing(sym, *args, &block)
          return @game.public_send(sym, *args, &block) if @game && @game.respond_to?(sym)
          super
        end

        private

        def set_attributes
          set_default_attributes
          set_brief_attributes if !(request.params.has_key? :brief) || request.params[:brief] == 0
          set_stat_attributes if request.params[:stats] && request.params[:stats] == 1
        end

        def set_default_attributes
          # Booleans
          @for_trade = xpath_value_boolean 'status/@fortrade'
          @owned = xpath_value_boolean 'status/@own'
          @preordered = xpath_value_boolean 'status/@preordered'
          @want_to_buy = xpath_value_boolean 'status/@wanttobuy'
          @want_to_play = xpath_value_boolean 'status/@wanttoplay'
          @wanted = xpath_value_boolean 'status/@want'

          # Dates
          @last_modified = xpath_value_time 'status/@lastmodified'

          # Integers
          @collection_id = xpath_value_int '@collid'
          @id = xpath_value_int '@objectid'
          @name = xpath_value 'name'
          @type = xpath_value '@subtype'
        end

        def set_brief_attributes
          # Integers
          @play_count = xpath_value_int 'numplays'
          @year_published = xpath_value_int 'yearpublished'

          # Strings
          @comment = xpath_value 'comment'
          @image = xpath_value 'image'
          @thumbnail = xpath_value 'thumbnail'
        end

        def set_stat_attributes
          # Floats
          @average_rating = xpath_value_float 'stats/rating/average/@value'
          @bgg_rating = xpath_value_float 'stats/rating/bayesaverage/@value'
          @user_rating = xpath_value_float 'stats/rating/@value'

          # Hashes
          @theme_ranks = xpath_value_ranks 'stats/rating/ranks/rank[@type="family"]'

          # Integers
          @own_count = xpath_value_int 'stats/@numowned'
          @play_time = xpath_value_int 'stats/@playingtime'
          @type_rank = xpath_value_int 'stats/rating/ranks/rank[@type="subtype"]/@value'

          # Range
          @players = xpath_value_range 'stats/@minplayers', 'stats/@maxplayers'
        end

        def xpath_value_range(start_path, end_path)
          min_players = xpath_value_int start_path
          max_players = xpath_value_int end_path
          (min_players and max_players) ?  min_players..max_players : nil
        end

        def xpath_value_time(path)
          time_string = xpath_value path
          Time.new(time_string) if time_string
        end

        def xpath_value_ranks(path)
          selected_ranks = @xml.xpath path
          selected_ranks.map do |rank|
            self.class::Rank.new rank, @request
          end unless selected_ranks.empty?
        end
      end
    end
  end
end
