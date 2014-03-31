module BracketGraph
  class Match
    # Match source seats
    attr_reader :from
    # Match winner seat
    attr_reader :winner
    # Match payload. Intended to be used for personal purposes
    attr_accessor :payload
    # The seat where the match winner will go
    attr_accessor :winner_to

    # Creates a new match
    #
    # @param winner_to [BracketGraph::Seat] the seat where the winner of the match will go
    def initialize winner_to
      @winner_to = winner_to
      create_children
    end

    # Graph depth until this level. It returns the destination depth + 1
    def depth
      @depth ||= winner_to.depth + 1
    end

    # Round is the opposite of depth. While depth is 0 in the root node and Math.log2(size) at the lower level
    # round is 0 at the lower level and Math.log2(size) in the root node
    # While depth is memoized, round is calculated each time. It returns the round of the first source seat
    def round
      from.first.round
    end

    # Returns the match loser
    # @return [nil] when the match has not been played
    # @return [BracketGraph::Seat] when the match has been played
    def loser
      winner && (from - [winner]).first || nil
    end

    # Sets the match winner and copies the winner payload to the winner seat. It automatically sets the loser too.
    # @param seat [BracketGraph::Seat] the winner seat
    # @raise [ArgumentError] if seat is not a BracketGraph::Seat
    # @raise [ArgumentError] if seat is not included between match source seats
    def winner= seat
      raise ArgumentError, 'A seat is required' unless seat.is_a? BracketGraph::Seat
      raise ArgumentError, 'You have to pass one of the match children' unless from.include? seat
      winner_to.payload = seat.payload
      @winner = seat
    end

    # Sets the match loser and copies the winner payload to the winner seat. It automatically sets the loser too.
    # @param seat [BracketGraph::Seat] the loser seat
    # @raise [ArgumentError] if seat is not a BracketGraph::Seat
    # @raise [ArgumentError] if seat is not included between match source seats
    def loser= seat
      raise ArgumentError, 'A seat is required' unless seat.is_a? BracketGraph::Seat
      raise ArgumentError, 'You have to pass one of the match children' unless from.include? seat
      self.winner = (from - [seat]).first
    end

    def marshal_dump
      { from: @from, winner: (@winner && @winner.position) }
    end

    def marshal_load data
      @from = data[:from]
      @from.each { |s| s.to = self }
      @winner = @from.detect { |s| s.position == data[:winner] } if data[:winner]
    end

    def to_json *attrs
      marshal_dump.to_json *attrs
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
