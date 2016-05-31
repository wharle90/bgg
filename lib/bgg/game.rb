module Bgg
  class Game
    attr_reader :alternate_names, :artists, :categories,
                :description, :designers, :families, :id,
                :image, :max_players, :mechanics, :min_players,
                :name, :names, :playing_time, :publishers,
                :recommended_minimum_age, :thumbnail,
                :year_published, :game_data

    class << self
      def find_batch_by_ids(game_ids, stats: 0)
        game_ids = game_ids.map { |id| Integer(id) }

        raise ArgumentError.new('game_ids must be greater than 0!') if game_ids.any? { |id| id < 1 }

        game_data = BggApi.thing id: game_ids.join(','), stats: stats

        raise ArgumentError.new('Games do not exist') unless game_data.has_key?('item')

        game_data['item'].map { |game| Game.new(game) }
      end

      def find_by_id(game_id, stats: false)
        game_id = Integer(game_id)

        raise ArgumentError.new('game_id must be greater than 0!') if game_id < 1

        game_data = BggApi.thing id: game_id, stats: stats ? 1 : 0

        raise ArgumentError.new('Game does not exist') unless game_data.has_key?('item')

        game_data = game_data['item'][0]

        Game.new(game_data)
      end
    end

    def initialize(game_data)
      @game_data = game_data

      @id = game_data['id'].to_i
      @names = game_data['name'].map{ |n| n['value'] }
      @name = game_data['name'].find{ |n| n.fetch('type', '') == 'primary'}['value']

      @alternate_names = @names.reject{ |name| name == @name }
      @artists = filter_links_for('boardgameartist')
      @categories = filter_links_for('boardgamecategory')
      @description = game_data['description'][0]
      @designers = filter_links_for('boardgamedesigner')
      @families = filter_links_for('boardgamefamily')
      @image = game_data['image'][0]
      @max_players = game_data['maxplayers'][0]['value'].to_i
      @mechanics = filter_links_for('boardgamemechanic')
      @min_players = game_data['minplayers'][0]['value'].to_i
      @playing_time = game_data['playingtime'][0]['value'].to_i
      @publishers = filter_links_for('boardgamepublisher')
      @recommended_minimum_age = game_data['minage'][0]['value'].to_i
      @thumbnail = game_data['thumbnail'][0]
      @year_published = game_data['yearpublished'][0]['value'].to_i
    end

    %i(one two three four five six seven eight nine ten).each_with_index do |word, i|
      i += 1
      define_method "best_with_#{word}?", proc { best_with.include? i.to_s }
      define_method "recommended_with_#{word}?", proc { recommended_with.include? i.to_s }
    end

    def best_with
      @best_with ||=
        player_count_votes.select do |player_count, votes|
          votes[:best] > votes[:recommended] + votes[:not_recommended]
        end.map(&:first)
    end

    def recommended_with
      @recommended_with ||=
        player_count_votes.select do |player_count, votes|
          votes[:best] + votes[:recommended] > votes[:not_recommended]
        end.map(&:first)
    end

    def player_count_votes
      @player_count_votes ||=
        begin
          extract_votes = -> (result, label) {
            result['result'].find do |r|
              r['value'] == label
            end['numvotes'].to_i
          }

          suggested_numplayers['results'].reduce({}) do |memo, result|
            # TODO: @jbodah 2016-05-29: handle games with no votes better
            next memo unless result['result']
            player_count = result['numplayers']
            memo[player_count] = {
              best:             extract_votes.(result, 'Best'),
              recommended:      extract_votes.(result, 'Recommended'),
              not_recommended:  extract_votes.(result, 'Not Recommended')
            }
            memo
          end
        end
    end

    def rating
      @rating ||= ratings['average'].first['value'].to_f
    end

    def weight
      @weight ||= ratings['averageweight'].first['value'].to_f
    end

    def very_light?;  weight > 0 && weight < 1.4;     end
    def light?;       weight >= 1.4 && weight < 2.3;  end
    def medium?;      weight >= 2.3 && weight < 3;    end
    def heavy?;       weight >= 3;                    end
    def very_heavy?;  weight >= 3.5;                  end

    def very_short?;      length <= 30;   end
    def short?;           length <= 45;   end
    def under_an_hour?;   length <= 60;   end
    def average?;         length <= 90;   end
    def under_two_hours?; length <= 120;  end
    def long?;            length >= 120;  end
    def very_long?;       length >= 180;  end

    def length
      @length ||= @game_data['playingtime'].first['value'].to_i
    end

    %i(trading owned wanting wishing).each do |sym|
      eval <<-EOF
        def count_#{sym}
          @count_#{sym} ||= ratings['#{sym}'].first['value']
        end
      EOF
    end

    def expansion?
      @game_data['type'] == 'boardgameexpansion'
    end

    def board_game?
      !expansion?
    end

    private

    def suggested_numplayers
      @suggested_numplayers ||=
        @game_data['poll'].find { |poll| poll['name'] == 'suggested_numplayers' }
    end

    def stats
      @game_data['statistics']
    end

    def ratings
      @ratings ||= stats.find { |h|  h['ratings'] }['ratings'].first
    end

    def filter_links_for(key)
      @game_data['link'].
        find_all { |l| l.fetch('type', '') == key }.
        map { |l| l['value'] }
    end
  end
end
