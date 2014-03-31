module BracketGraph
  class Seat
    attr_reader :from, :to, :depth

    def initialize to = nil
      @to = to
      @depth = to && to.depth || 0
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
