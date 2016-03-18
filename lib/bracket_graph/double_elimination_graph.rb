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

    def winner_starting_seats
      winner_graph.starting_seats
    end

    def winner_seats
      winner_graph.seats
    end

    def winner_root
      winner_graph.root
    end

    def loser_starting_seats
      loser_graph.starting_seats
    end

    def loser_seats
      loser_graph.seats
    end

    def loser_root
      loser_graph.root
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
