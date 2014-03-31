module BracketGraph
  class Graph
    attr_reader :root
    attr_reader :starting_seats, :seats, :matches

    def initialize size
      raise ArgumentError, 'the given size is not a power of 2' if Math.log2(size) % 1 != 0
      build_tree size
    end

    def size
      starting_seats.size
    end

    def seed teams, shuffle: false
      teams = prepare_teams_for_seed teams, shuffle: shuffle
      starting_seats.each do |seat|
        seat.payload = teams.shift
      end
    end

    def marshal_dump
      @root
    end

    def marshal_load data
      @root = data
      update_references
    end

    private

    def prepare_teams_for_seed teams, shuffle: false
      teams = teams + ([nil] * (size - teams.size))
      teams.tap do |teams|
        teams.shuffle! if shuffle
      end
    end

    def build_tree size
      @root = Seat.new size
      Math.log2(size).to_i.times.inject [root] do |seats|
        seats.inject [] do |memo, seat|
          memo.concat seat.build_input_match.from
        end
      end
      update_references
    end

    def update_references
      @seats = [root]
      @matches = []
      current_seats = [root]
      root.round.times { current_seats = update_references_for_seats current_seats }
      @starting_seats = current_seats
    end

    def update_references_for_seats seats
      seats.inject [] do |memo, seat|
        match = seat.from
        @matches << match
        @seats.concat(match.from) && memo.concat(match.from)
      end
    end
  end
end
