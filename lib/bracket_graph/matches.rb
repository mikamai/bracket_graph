module BracketGraph
  class Matches < Array
    def in_round round_index
      select { |o| o.round == round_index }
    end
  end
end