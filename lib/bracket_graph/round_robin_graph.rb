module BracketGraph
  class RoundRobinGraph
    attr_reader :starting_seats, :seats, :double_match

    # Builds a new RoundRobin graph.
    # The graph will be composed by `size` starting seats in each round
    # each couple of starting seat point to a match seat and stop there
    #
    # @param size [Fixnum] The number of orphan seat to generate
    # @param double_match [true, false] Indicates if the graph is for a double match round robin
    # @raise [ArgumentError] if size is not a multiple of 2
    def initialize size, double_match: false
      raise ArgumentError, 'the given size is not a multiple of 2' if size % 2 != 0
      @seats = []
      @double_match = double_match
      build_tree size
    end

    # returns the seat in a certain position
    def [](position)
      seats.detect { |s| s.position == position }
    end

    # Number of starting seats at the first round
    def size
      # gets only the seats from the first round
      starting_seats.select{ |s| s.round == 0 }.size
    end

    # returns the starting seats of a given round
    def starting_seats_by_round round
      starting_seats.select { |s| s.round == round }
    end

    # Fills the starting seats with the given `teams`
    #
    # In each round the `teams` are shifted by one starting from the second position
    # to respect the following schema:
    #
    # teams = [1,2,3,4]
    # round_1: starting_seats.map(&:payload) = [1,4,2,3] (1vs4 - 2vs3)
    # round_2: starting_seats.map(&:payload) = [1,3,4,2] (1vs3 - 4vs2)
    # round_3: starting_seats.map(&:payload) = [1,2,3,4] (1vs2 - 3vs4)
    #
    # @param teams [Array] Team to place as payload in the starting seats
    # @param shuffle [true, false] Indicates if teams shoud be shuffled
    # @raise [ArgumentError] if `teams.count` is greater then `#size`
    def seed teams, shuffle: false
      raise ArgumentError, "Only a maximum of #{size} teams is allowed" if teams.size > size
      slots = TeamSeeder.new(teams, size, shuffle: shuffle).slots
      starting_seats.map(&:round).uniq.each do |round|
        starting_seats_by_round(round).each_slice(2).each_with_index do |pair, index|
          home, away = pair
          away, home = pair if return_round? round
          home.payload = slots[index]
          away.payload = slots.reverse[index]
        end
        slots = [slots[0]] + slots[1..-1].rotate(-1)
      end
    end

    private

    def build_tree size
      build_tree! size
      update_references
    end

    def build_tree! size
      # rounds
      @position = 1
      rounds_count(size).times.each do |round|
        (size/2).times.each do |match_number|
          root = Seat.new @position, round: round
          @seats.concat [root].concat(create_children_of root)
          @position += 1
        end
      end
    end

    def rounds_count size
      return size - 1 unless double_match
      size * 2 - 2
    end

    def max_round
      starting_seats.map(&:round).max
    end

    def return_round? round
      return false unless double_match
      round > max_round / 2
    end

    def update_references
      @starting_seats = @seats.flatten.select { |s| s.from.empty? }
    end

    def create_children_of seat
      home = @position += 1
      away = @position += 1
      seat.from.concat [
        Seat.new(home, to: seat, round: seat.round),
        Seat.new(away, to: seat, round: seat.round),
      ]
    end
  end
end