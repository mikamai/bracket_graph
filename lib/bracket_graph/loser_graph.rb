require "bracket_graph/graph"

module BracketGraph
  class LoserGraph < Graph
    class IdGenerator
      def initialize
        @last_id = 0
      end

      def next
        @last_id += 1
      end
    end

    def initialize size
      raise ArgumentError, 'a loser graph require at least 4 participants' if size < 4
      super
    end

    private

    def build_tree size
      id_generator = IdGenerator.new
      @root = Seat.new id_generator.next, round: 2 * Math.log2(size).to_i - 2
      expected_rounds = 2 * (Math.log2(size).to_i - 1)
      expected_rounds.times.inject [root] do |seats, round|
        seats.each_with_index.inject [] do |memo, (seat, index)|
          children = create_children_of seat, id_generator
          if round.even?
            memo << children[index > seats.count / 2 ? 0 : 1]
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
