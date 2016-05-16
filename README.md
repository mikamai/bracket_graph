# BracketGraph

Bracket Graph Library.

It helps managing a graph for a single elimination bracket where each seat leads to a match that leads to a winner seat.

## Single Elimination Bracket

```ruby
BracketGraph::Graph.new(bracket_size)
```

## About the Graph object

```ruby
graph.root # => BracketGraph::Seat for the final match
graph.seats # => Array[BracketGraph::Seat] all nodes
graph.starting_seats # => Array[BracketGraph::Seat] all starting nodes
graph[12] # => BracketGraph::Seat with id/position 12
graph.seed(teams) # => seeds each item in the given array to a starting node
graph.seed(teams, shuffle: true) # => seeds teams after shuffle
```

## About the Graph nodes

```ruby
seat.from # Array[BracketGraph::Seat] source nodes. Empty array for a starting node
seat.to # parent node. nil for the final node
seat.position # node position id
seat.payload # custom payload that can be also seeded via BracketGraph::Graph#seed
```

## Double Elimination Bracket

```ruby
BracketGraph::DoubleEliminationGraph.new(bracket_size)
```

## About the Graph objects

```ruby
graph.root # => BracketGraph::Seat for the final match
graph.winner_graph # => BracketGraph::Graph for the the winner bracket
graph.loser_graph # => BracketGraph::LoserGraph for the the loser bracket
graph[12] # => BracketGraph::Seat with id/position 12
graph.seed(teams) # => seeds each item in the given array to a starting node in the winner_graph
graph.seed(teams, shuffle: true) # => seeds teams after shuffle
```

### Winner Graph object

```ruby
graph.winner_root # => BracketGraph::Seat for the final match of the winner bracket
graph.winner_seats # => Array[BracketGraph::Seat] all nodes of the winner bracket
graph.winner_starting_seats # => Array[BracketGraph::Seat] all starting nodes of the winner bracket
```

### Loser Graph object

```ruby
graph.loser_root # => BracketGraph::Seat for the final match of the loser bracket
graph.loser_seats # => Array[BracketGraph::Seat] all nodes of the loser bracket
graph.loser_starting_seats # => Array[BracketGraph::Seat] all starting nodes of the loser bracket
```

## Round Robin "Bracket"

This is a different object from the previous. A Round Robin Tournament can't be viewed as tree, it's more likes tables. In this object every match in a round is a mini tree, the match is the "root" node and the two children are the starting seats.

This results in a lot of starting seats divided accross the rounds. For example, in a Round Robin Tournament for 4 teams the object creates 12 starting seats, 4 for each of the 3 rounds. In every round we will have 2 match, for a total of 6 matches.

If we need a Round Robin Tournament with the "return match" (`double_match: true`), always for 4 teams, this time the object creates 6 rounds.
The difference is, when we call the `seed` method, it fills the starting seats one time with the right position (1vs2) and one time with the position swapped (2vs1) if the match is a "return match" in this way we play against an opponent once as home and once as away.

At the end, we need an external object that take care of calculate the leaderboard and find out the winners (can be more than one).

```ruby
BracketGraph::RoundRobinGraph.new(bracket_size, double_match: false) # => if the double_match is true the graph will have the double of match and starting seats
```

## About the Graph objects

```ruby
graph.starting_seats # => Array[BracketGraph::Seat] all starting seats (N for each round)
graph[12] # => BracketGraph::Seat with id/position 12
graph.seed(teams) # => seeds each item in the given array to a starting node in each round
graph.seed(teams, shuffle: true) # => seeds teams after shuffle
```
