module BracketGraph
  class Seat
    attr_accessor :from
    attr_accessor :to

    def initialize to = nil, from = nil
      @from, @to = from, to
    end

    def build_input_match
      raise NoMethodError, 'you cannot build a source match again' if from
      @from = Match.new self
    end
  end
end
