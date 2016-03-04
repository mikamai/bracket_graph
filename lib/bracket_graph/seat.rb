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
    def initialize position, to: nil, round: nil
      @position, @to, @round = position, to, round
      @from = []
    end

    # Graph depth until this level. If there is no destination it will return 0, otherwise it will return the destionation depth
    def depth
      @depth ||= to && to.depth + 1 || 0
    end

    # Round is the opposite of depth. While depth is 0 in the root node and Math.log2(size) at the lower level
    # round is 0 at the lower level and Math.log2(size) in the root node
    # While depth is memoized, round is calculated each time. If the seat has a source, it's the source round + 1, otherwise it's 0
    def round
      @round || to.round - 1
    end

    def marshal_dump
      data = { position: position }
      data[:round] = @round if @round
      from && data.update(from: from) || data
    end

    def marshal_load data
      @position = data[:position]
      @from = data[:from]
      @round = data[:round]
      @from && @from.each { |s| s.to = self }
    end

    def as_json options = {}
      data = { position: position }
      data.update payload: payload if payload
      from && data.update(from: from.map(&:as_json)) || data
    end

    def to_json *attrs
      as_json.to_json(*attrs)
    end

    def inspect
      """#<BracketGraph::Seat:#{position}
      @from=#{from.map(&:position).inspect}
      @to=#{(to && to.position || nil).inspect}
      @payload=#{payload.inspect}>"""
    end
  end
end
