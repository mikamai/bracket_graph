require 'spec_helper'

describe BracketGraph::LoserGraph do
  describe 'constructor' do
    it 'creates instance with a certain size' do
      expect { described_class.new 128 }.to_not raise_error
    end

    it 'raises error if size is not a power of 2' do
      expect { described_class.new 5 }.to raise_error ArgumentError
    end

    it 'raises error if size is lower than 4' do
      expect { described_class.new 2 }.to raise_error ArgumentError
    end

    it 'creates a root seat node' do
      subject = described_class.new 4
      expect(subject.root).to be_a BracketGraph::Seat
    end

    it 'appends two seats as input in the root match node' do
      subject = described_class.new 4
      expect(subject.root.from.map(&:class)).to eq [BracketGraph::Seat,BracketGraph::Seat]
    end

    it 'one of the root children is a starting seat' do
      subject = described_class.new 4
      expect(subject.root.from.map(&:from)).to include []
    end

    it 'the children of the match child of root are starting seats' do
      subject = described_class.new 4
      expect(subject.root.from.map(&:from).flatten.map(&:from).flatten).to be_empty
    end

    it 'follows this pattern until the last level children count is equal to the graph size' do
      subject = described_class.new 128
      nodes = 6.times.inject([subject.root]) do |current_nodes|
        current_nodes.inject([]) do |memo, node|
          expect(node.from.count).to eq 2
          sub_children = node.from.map &:from
          expect(sub_children).to include []
          expect(sub_children.flatten.count).to eq 2
          memo.concat sub_children.flatten
        end
      end
      expect(nodes.count).to eq 64
      nodes.each { |node| expect(node.from).to be_empty }
    end

    it 'sets depths starting from 0' do
      subject = described_class.new 128
      expect(subject.root.depth).to eq 0
    end

    it 'contains starting seats in even seats' do
      subject = described_class.new 128
      expect(subject.starting_seats.map(&:depth).uniq).to eq [1,3,5,7,9,11,12]
    end

    it 'sets rounds starting from 2 per log2 of size - 1' do
      subject = described_class.new 128
      expect(subject.root.round).to eq 12
    end

    it 'contains starting seats in odd seats' do
      subject = described_class.new 128
      expect(subject.starting_seats.map(&:round).uniq).to eq [11,9,7,5,3,1,0]
    end

    it 'sets root position to doubled size + 2' do
      subject = described_class.new 64
      expect(subject.root.position).to eq 130
    end

    it 'sets the position of root children to root position +1 and +2' do
      subject = described_class.new 64
      expect(subject.root.from.map(&:position)).to match_array [131,132]
    end

    it 'sets source seats (through the match) positions' do
      subject = described_class.new 64
      children = subject.root.from[1].from
      expect(children.map(&:position).sort).to eq [133, 134]
    end

    it 'does not duplicate positions' do
      subject = described_class.new 16
      expect(subject.seats.map(&:position).uniq.count).to eq subject.seats.count
    end

    it 'creates a graph given its root node' do
      existing = described_class.new 4
      subject = described_class.new existing.root
      expect(subject.starting_seats).to eq existing.starting_seats
    end
  end

  describe '#starting_seats' do
    it 'returns a collection of the given size - 1' do
      subject = described_class.new 128
      expect(subject.starting_seats.count).to eq 127
    end

    it 'returns a collection of seats' do
      subject = described_class.new 8
      expect(subject.starting_seats.map(&:class).uniq).to eq [BracketGraph::Seat]
    end

    it 'returns the last level seats' do
      subject = described_class.new 8
      subject.starting_seats.each do |seat|
        expect(seat.from).to be_empty
      end
    end
  end

  describe '#[]' do
    it 'return the seat with the given position' do
      subject = described_class.new 8
      expect(subject[22].position).to eq 22
    end
  end

  describe '#seats' do
    it 'returns seats' do
      subject = described_class.new 8
      expect(subject.seats.map(&:class).uniq).to eq [BracketGraph::Seat]
    end

    it 'returns all generated seats' do
      subject = described_class.new 8
      expect(subject.seats.count).to eq 13
    end

    it 'returns the root node too' do
      subject = described_class.new 8
      expect(subject.seats).to include subject.root
    end
  end
end
