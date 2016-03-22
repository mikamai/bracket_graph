module BracketGraph
  class DoubleEliminationGraph
    attr_reader :root
    attr_reader :winner_graph, :loser_graph

    def initialize size
      @winner_graph = Graph.new size
      @loser_graph = LoserGraph.new size
      sync_winner_rounds
      sync_loser_rounds
      build_final_seat
    end

    def [](position)
      return root if position == root.position
      if position < root.position
        winner_graph[position]
      else
        loser_graph[position]
      end
    end

    def size
      winner_graph.size
    end

    %w(winner loser).each do |type|
      define_method "#{type}_starting_seats" do
        send("#{type}_graph").starting_seats
      end

      define_method "#{type}_seats" do
        send("#{type}_graph").seats
      end

      define_method "#{type}_root" do
        send("#{type}_graph").root
      end
    end

    def seats
      winner_seats + loser_seats
    end

    def starting_seats
      winner_starting_seats + loser_starting_seats
    end

    def seed *args
      winner_graph.seed *args
    end

    def marshal_dump
      # we need only the root node. All other variables can be restored on load
      @root
    end

    def marshal_load data
      @root = data
      @winner_graph = Graph.new @root.from[0]
      @loser_graph = LoserGraph.new @root.from[1]
    end

    def as_json options={}
      marshal_dump.as_json options
    end

    private

    def build_final_seat
      @root = Seat.new size * 2, round: loser_graph.root.round + 1
      @root.from.concat [winner_graph.root, loser_graph.root]
      @root.from.each { |s| s.to = @root }
    end

    def sync_winner_rounds
      seats_by_round = winner_seats.inject({}) do |memo, seat|
        memo[seat.round] ||= []
        memo[seat.round] << seat
        memo
      end
      3.upto(winner_root.round) do |round|
        seats_by_round[round].each do |r|
          r.instance_variable_set '@round', 2 + (round - 2) * 2
        end
      end
    end

    def sync_loser_rounds
      loser_graph.seats.each do |s|
        s.instance_variable_set '@round', s.round + 1
      end
    end
  end
end
