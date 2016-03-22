module BracketGraph
  class Graph
    attr_reader :root
    attr_reader :starting_seats, :seats

    # Builds a new graph.
    # The graph will be composed by a root seat and a match with two seats pointing to the root seat
    # Each seat will then follows the same template (seat -> match -> 2 seats) until the generated
    # last level seats (the starting seats) is equal to `size`.
    #
    # @param size [Fixnum|Seat] The number of orphan seats to generate, or the root node
    # @raise [ArgumentError] if size is not a power of 2
    def initialize root_or_size
      if root_or_size.is_a? Seat
        marshal_load root_or_size
      else
        raise ArgumentError, 'the given size is not a power of 2' if Math.log2(root_or_size) % 1 != 0
        build_tree root_or_size
      end
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
      slots = TeamSeeder.new(teams, size, shuffle: shuffle).slots
      starting_seats.sort_by(&:position).each do |seat|
        seat.payload = slots.shift
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
      # backward compatibility
      @root.instance_variable_set '@round', Math.log2(size).to_i if @root.round.zero?
    end

    def as_json *attrs
      marshal_dump.as_json *attrs
    end

    private

    def build_tree size
      build_tree! size
      update_references
    end

    def build_tree! size
      @root = Seat.new size, round: Math.log2(size).to_i
      # Math.log2(size) indicates the graph depth
      Math.log2(size).to_i.times.inject [root] do |seats|
        seats.inject [] do |memo, seat|
          memo.concat create_children_of seat
        end
      end

    end

    def update_references
      @seats = [root]
      @starting_seats = []
      nodes = [root]
      while nodes.any?
        @seats.concat nodes = nodes.map(&:from).flatten
      end
      @starting_seats = @seats.select { |s| s.from.empty? }
    end

    # Builds a match as a source of this seat
    # @raise [NoMethodError] if a source match has already been set
    def create_children_of seat
      raise NoMethodError, 'children already built' if seat.from.any?
      parent_position = seat.to ? seat.to.position : 0
      relative_position_halved = (seat.position - parent_position) / 2
      seat.from.concat [
        Seat.new(seat.position - relative_position_halved, to: seat),
        Seat.new(seat.position + relative_position_halved, to: seat)
      ]
    end
  end
end
