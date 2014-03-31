module BracketGraph
  class Seat
    # Source match for this seat
    attr_reader :from
    # Seat position in the graph. It acts like an Id
    attr_reader :position
    # Seat payload. It should be used to keep track of the player and of its status in this seat
    attr_accessor :payload
    # Destination match of this seat.
    attr_accessor :to

    # Creates a new seat for the bracket graph.
    #
    # @param position [Fixnum] Indicates the Seat position in the graph and acts like an Id
    # @param to [BracketGraph::Match] The destination match. By default it's nil (and this node will act like the root node)
    def initialize position, to = nil
      @position, @to = position, to
    end

    # Graph depth until this level. If there is no destination it will return 0, otherwise it will return the destionation depth
    def depth
      @depth ||= to && to.depth || 0
    end

    # The seat where the winner of the destination match will go
    def to_winner_seat
      to.winner_to
    end

    # Round is the opposite of depth. While depth is 0 in the root node and Math.log2(size) at the lower level
    # round is 0 at the lower level and Math.log2(size) in the root node
    # While depth is memoized, round is calculated each time. If the seat has a source, it's the source round + 1, otherwise it's 0
    def round
      from && from.round + 1 || 0
    end

    # Builds a match as a source of this seat
    # @raise [NoMethodError] if a source match has already been set
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
