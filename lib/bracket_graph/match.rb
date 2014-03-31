module BracketGraph
  class Match
    attr_reader :from, :winner_to, :depth

    def initialize winner_to
      @winner_to = winner_to
      @depth = @winner_to.depth + 1
      create_children
    end

    def round
      from.first.round
    end

    private

    def create_children
      dest_pos = winner_to.position
      dest_pos_halved = dest_pos / 2
      @from = [
        Seat.new(dest_pos - dest_pos_halved, self),
        Seat.new(dest_pos + dest_pos_halved, self)
      ]
    end
  end
end
