module Bgg
  class Game
    attr_reader :alternate_names, :artists, :categories,
                :description, :designers, :families, :id,
                :image, :max_players, :mechanics, :min_players,
                :name, :names, :playing_time, :publishers,
                :recommended_minimum_age, :thumbnail,
                :year_published, :game_data

    def self.find_by_id(game_id, stats: false)
      game_id = Integer(game_id)

      raise ArgumentError.new('game_id must be greater than 0!') if game_id < 1

      game_data = BggApi.thing({
        id: game_id,
        stats: stats ? 1 : 0
      })

      raise ArgumentError.new('Game does not exist') unless game_data.has_key?('item')

      game_data = game_data['item'][0]

      Game.new(game_data)
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

    def best_with
      player_count_votes.select do |player_count, votes|
        votes[:best] > votes[:recommended] + votes[:not_recommended]
      end.map(&:first)
    end

    def recommended_with
      player_count_votes.select do |player_count, votes|
        votes[:best] + votes[:recommended] > votes[:not_recommended]
      end.map(&:first)
    end

    def player_count_votes
      @player_count_votes ||= begin
                                extract_votes = -> (result, label) {
                                  result['result'].find do |r|
                                    r['value'] == label
                                  end['numvotes'].to_i
                                }

                                suggested_numplayers['results'].reduce({}) do |memo, result|
                                  # TODO: @jbodah 2016-05-29: handle games with no votes better
                                  next unless result['result']
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

    def suggested_numplayers
      @suggested_numplayers ||=
        @game_data['poll'].find { |poll| poll['name'] == 'suggested_numplayers' }
    end

    end

    private

    def filter_links_for(key)
      @game_data['link'].
        find_all{ |l| l.fetch('type', '') == key }.
        map{ |l| l['value'] }
    end
  end
end
