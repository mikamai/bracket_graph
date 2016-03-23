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
    # Destination match of this seat for the loser participant.
    attr_accessor :loser_to

    # Creates a new seat for the bracket graph.
    #
    # @param position [Fixnum] Indicates the Seat position in the graph and acts like an Id
    # @param to [BracketGraph::Match] The destination match. By default it's nil (and this node will act like the root node)
    def initialize position, to: nil, round: nil
      round ||= to.round - 1 if to
      @position, @to, @round = position, to, round
      @from = []
    end

    def starting?
      from.nil? || from.empty?
    end

    def final?
      to.nil?
    end

    # Graph depth until this level. If there is no destination it will return 0, otherwise it will return the destionation depth
    def depth
      @depth ||= to && to.depth + 1 || 0
    end

    # Round is the opposite of depth. While depth is 0 in the root node and Math.log2(size) at the lower level
    # round is 0 at the lower level and Math.log2(size) in the root node
    # While depth is memoized, round is calculated each time. If the seat has a source, it's the source round + 1, otherwise it's 0
    def round
      @round || (to ? to.round - 1 : 0)
    end

    def marshal_dump
      data = { position: position, round: round }
      from && from.any? ? data.update(from: from) : data
    end

    def marshal_load data
      @position = data[:position]
      @from = data[:from] || []
      @round = data[:round] || 0
      @from && @from.each { |s| s.to = self }
    end

    def as_json options = {}
      data = { position: position, round: round }
      data.update payload: payload if payload
      data.update loser_to: loser_to.position if loser_to
      from && data.update(from: from.map(&:as_json)) || data
    end

    def inspect
      """#<BracketGraph::Seat:#{position}
      @from=#{from.map(&:position).inspect}
      @round=#{round}
      @to=#{(to && to.position || nil).inspect}
      @loser_to=#{(loser_to && loser_to.position || nil).inspect}
      @payload=#{payload.inspect}>"""
    end
  end
end
