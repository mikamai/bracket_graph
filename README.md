# BracketGraph

Bracket Graph Library.

It helps managing a graph for a single elimination bracket where each seat leads to a match that leads to a winner seat.

## Single Elimination Bracket / Double Elimination Winner Bracket

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
