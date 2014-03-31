module BracketGraph
  class Seat
    attr_reader :from, :position
    attr_accessor :payload, :to

    def initialize position, to = nil
      @position, @to = position, to
    end

    def depth
      @depth ||= to && to.depth || 0
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

    def marshal_dump
      { position: @position, from: @from }
    end

    def marshal_load data
      @position = data[:position]
      @from = data[:from]
      @from && @from.winner_to = self
    end

    def to_json *attrs
      marshal_dump.to_json(*attrs)
    end
  end
end
