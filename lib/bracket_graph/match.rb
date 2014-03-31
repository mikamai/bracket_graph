module BracketGraph
  class Match
    attr_reader :from, :winner_to, :depth

    def initialize winner_to, from = []
      raise ArgumentError, 'source argument must be an array of source nodes' unless from.is_a? Array
      @from = from
      @winner_to = winner_to
      @depth = @winner_to.depth + 1
    end

    def build_input_seats
      @from = [Seat.new(self), Seat.new(self)]
    end
  end
end
