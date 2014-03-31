module BracketGraph
  class Match
    attr_reader :from, :winner
    attr_accessor :payload, :winner_to

    def initialize winner_to
      @winner_to = winner_to
      create_children
    end

    def depth
      @depth ||= winner_to.depth + 1
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
