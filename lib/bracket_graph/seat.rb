module BracketGraph
  class Seat
    attr_reader :from, :to, :depth, :position

    def initialize position, to = nil
      @position, @to = position, to
      @depth = to && to.depth || 0
    end

    def to_winner_seat
      to.winner_to
    end

    def round
      from && from.round + 1 || 0
    end

    def build_input_match
      raise NoMethodError, 'you cannot build a source match again' if from
      @from = Match.new self
    end
  end
end
