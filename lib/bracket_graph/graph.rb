module BracketGraph
  class Graph
    attr_reader :root
    attr_reader :starting_seats, :seats

    # Builds a new graph.
    # The graph will be composed by a root seat and a match with two seats pointing to the root seat
    # Each seat will then follows the same template (seat -> match -> 2 seats) until the generated
    # last level seats (the starting seats) is equal to `size`.
    #
    # @param size [Fixnum] The number of orphan seats to generate.
    # @raise [ArgumentError] if size is not a power of 2
    def initialize size
      raise ArgumentError, 'the given size is not a power of 2' if Math.log2(size) % 1 != 0
      build_tree size
    end

    def [](position)
      seats.detect { |s| s.position == position }
    end

    # Number of the starting seats
    def size
      starting_seats.size
    end

    # Fills the starting seats with the given `teams`
    #
    # @param teams [Array] Teams to place as payload in the starting seats
    # @param shuffle [true, false] Indicates if teams shoud be shuffled
    # @raise [ArgumentError] if `teams.count` is greater then `#size`
    def seed teams, shuffle: false
      raise ArgumentError, "Only a maximum of #{size} teams is allowed" if teams.size > size
      teams = prepare_teams_for_seed teams, shuffle: shuffle
      starting_seats.each do |seat|
        seat.payload = teams.shift
      end
    end

    def marshal_dump
      # we need only the root node. All other variables can be restored on load
      @root
    end

    def marshal_load data
      @root = data
      # After loading the root node, regenerate all references
      update_references
    end

    def to_json *attrs
      marshal_dump.to_json *attrs
    end

    private

    def prepare_teams_for_seed teams, shuffle: false
      teams = shuffle && teams.shuffle || teams.dup
      (size - teams.size).times do |i|
        nil_index = i * 2 > teams.size ? teams.size : i * 2
        teams.insert nil_index, nil
      end
      teams
    end

    def build_tree size
      @root = Seat.new size
      # Math.log2(size) indicates the graph depth
      Math.log2(size).to_i.times.inject [root] do |seats|
        seats.inject [] do |memo, seat|
          memo.concat seat.create_children
        end
      end
      update_references
    end

    def update_references
      @seats = [root]
      current_seats = [root]
      root.round.times { current_seats = update_references_for_seats current_seats }
      @starting_seats = current_seats
    end

    def update_references_for_seats seats
      seats.inject [] do |memo, seat|
        @seats.concat(seat.from) && memo.concat(seat.from)
      end
    end
  end
end
