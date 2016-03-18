require 'spec_helper'

describe BracketGraph::DoubleEliminationGraph do
  it 'creates a graph composed by winner and loser graphs' do
    subject = described_class.new 8
    expect(subject.winner_graph).to be_a BracketGraph::Graph
    expect(subject.loser_graph).to be_a BracketGraph::LoserGraph
  end

  it 'creates both the sub-graphs with the same size' do
    subject = described_class.new 8
    expect(subject.winner_graph.size).to eq 8
    expect(subject.loser_graph.size).to eq 8
  end

  it 'creates a real final node' do
    subject = described_class.new 8
    expect(subject.root).to be_a BracketGraph::Seat
  end

  it 'binds both the sub-graph roots as children of the real final node' do
    subject = described_class.new 8
    expect(subject.winner_graph.root.to).to eq subject.root
    expect(subject.loser_graph.root.to).to eq subject.root
    expect(subject.root.from).to eq [subject.winner_graph.root, subject.loser_graph.root]
  end

  it 'creates the final node with doubled size as position' do
    subject = described_class.new 8
    expect(subject.root.position).to eq 16
  end

  it 'creates the final node in the last round' do
    subject = described_class.new 8
    expect(subject.root.round).to eq 5
  end

  describe '#size' do
    it 'returns the right size' do
      subject = described_class.new 8
      expect(subject.size).to eq 8
    end
  end

  describe '#starting_seats' do
    it 'returns the sum of starting seats' do
      subject = described_class.new 8
      expect(subject.starting_seats).to match_array subject.winner_graph.starting_seats + subject.loser_graph.starting_seats
    end
  end

  describe '#seats' do
    it 'returns the sum of seats' do
      subject = described_class.new 8
      expect(subject.seats).to match_array subject.winner_graph.seats + subject.loser_graph.seats
    end
  end

  describe '#seeds' do
    it 'delegates to the winner graph' do
      subject = described_class.new 8
      allow(subject.winner_graph).to receive(:seed).and_return 'foo'
      expect(subject.seed).to eq 'foo'
    end
  end
end
