module BracketGraph
  class Match
    attr_accessor :from
    attr_accessor :winner_to

    def initialize winner_to = nil, from = []
      raise ArgumentError, 'source argument must be an array of source nodes' unless from.is_a? Array
      @from = from
      @winner_to = winner_to
    end

    def build_input_seats
      @from = [Seat.new(self), Seat.new(self)]
    end
  end
end
