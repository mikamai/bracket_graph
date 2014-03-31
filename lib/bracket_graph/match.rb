module BracketGraph
  class Match
    attr_reader :from, :winner_to, :depth, :winner
    attr_accessor :payload

    def initialize winner_to
      @winner_to = winner_to
      @depth = @winner_to.depth + 1
      create_children
    end

    def round
      from.first.round
    end

    def loser
      winner && (from - [winner]).first || nil
    end

    def winner= seat
      raise ArgumentError, 'A seat is required' unless seat.is_a? BracketGraph::Seat
      raise ArgumentError, 'You have to pass one of the match children' unless from.include? seat
      winner_to.payload = seat.payload
      @winner = seat
    end

    def loser= seat
      raise ArgumentError, 'A seat is required' unless seat.is_a? BracketGraph::Seat
      raise ArgumentError, 'You have to pass one of the match children' unless from.include? seat
      self.winner = (from - [seat]).first
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
