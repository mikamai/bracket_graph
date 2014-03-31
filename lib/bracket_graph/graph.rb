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

    private

    def prepare_teams_for_seed teams, shuffle: false
      teams = teams + ([nil] * (size - teams.size))
      teams.tap do |teams|
        teams.shuffle! if shuffle
      end
    end

    def build_tree size
      @root = Seat.new size
      @seats = [root]
      @matches = []
      current_nodes = [root]
      while current_nodes.size < size
        current_nodes = create_matches_for_nodes current_nodes
      end
      @starting_seats = current_nodes
    end

    def create_matches_for_nodes seats
      seats.inject([]) do |memo, seat|
        memo.concat create_match_and_memoize_nodes(seat)
      end
    end

    def create_match_and_memoize_nodes seat
      match = seat.build_input_match
      @matches << match
      @seats.concat match.from
      match.from
    end
  end
end
