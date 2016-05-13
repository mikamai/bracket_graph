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
