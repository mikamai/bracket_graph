require "bracket_graph/graph"

module BracketGraph
  class LoserGraph < Graph
    class IdGenerator
      attr_reader :current

      def initialize starting_id = 0
        @current = starting_id
      end

      def next
        @current += 1
      end
    end

    def initialize root_or_size
      raise ArgumentError, 'a loser graph require at least 4 participants' if root_or_size.is_a?(Fixnum) && root_or_size < 4
      super
    end

    def size
      starting_seats.count + 1
    end

    private

    def build_tree size
      id_generator = IdGenerator.new size * 2 + 1
      @root = Seat.new id_generator.next, round: 2 * Math.log2(size).to_i - 2
      expected_rounds = 2 * (Math.log2(size).to_i - 1)
      expected_rounds.times.inject [root] do |seats, round|
        seats.each_with_index.inject [] do |memo, (seat, index)|
          children = create_children_of seat, id_generator
          side_count = (seats.count / 2.0).ceil
          if round.even?
            memo << children[index % side_count >= (side_count / 2.0).ceil ? 0 : 1]
          else
            memo.concat children
          end
        end
      end
      update_references
    end

    # Builds a match as a source of this seat
    # @raise [NoMethodError] if a source match has already been set
    def create_children_of seat, id_generator
      raise NoMethodError, 'children already built' if seat.from.any?
      seat.from.concat [
        Seat.new(id_generator.next, to: seat),
        Seat.new(id_generator.next, to: seat)
      ]
    end
  end
end
