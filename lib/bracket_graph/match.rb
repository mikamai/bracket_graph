module BracketGraph
  class Match
    attr_reader :from, :winner_to, :depth

    def initialize winner_to
      @winner_to = winner_to
      @depth = @winner_to.depth + 1
      @from = [Seat.new(self), Seat.new(self)]
    end

    def round
      from.first.round
    end
  end
end
