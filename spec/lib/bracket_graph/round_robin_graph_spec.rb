require 'spec_helper'

describe BracketGraph::RoundRobinGraph do
  describe 'constructor' do
    it 'creates instance with a certain size' do
      expect { described_class.new 128 }.to_not raise_error
    end

    it 'raises error if size is not a power of 2' do
      expect { described_class.new 3 }.to raise_error ArgumentError
    end

    it 'creates 12 starting seats' do
      subject = described_class.new 4
      expect(subject.starting_seats.size).to eq 12
    end

    it 'creates one round less than the size' do
      subject = described_class.new 6
      expect(subject.seats.map(&:round).uniq.size).to eq 5
    end

    it 'sets the match seat to (N * 3) - 2' do
      subject = described_class.new 4
      1.upto(6).each do |n|
        position = (n*3) - 2
        expect(subject[position].from).to_not be_empty
      end
    end

    it 'sets source seats (through the match) to position +1 and +2' do
      subject = described_class.new 4
      children = subject[1].from
      expect(children.map(&:position).sort).to eq [2,3]
    end

    it 'does not duplicate positions' do
      subject = described_class.new 128
      expect(subject.seats.map(&:position).uniq.count).to eq subject.seats.count
    end

    it 'always sets the children by position order' do
      subject = described_class.new 32
      positions_groups = subject.seats.map { |s| s.from.map &:position }
      positions_groups.each do |position_group|
        expect(position_group).to eq position_group.sort
      end
    end

    context 'when the return match should be played' do
      it 'creates 24 starting seats' do
        subject = described_class.new 4, double_match: true
        expect(subject.starting_seats.size).to eq 24
      end
    end
  end

  describe '#starting_seats' do
    it 'returns a collection of round * size' do
      subject = described_class.new 6
      expect(subject.starting_seats.count).to eq 30
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

  describe '#seed' do
    it 'raises error if there are more teams than starting seats' do
      subject = described_class.new 4
      expect { subject.seed [1,2,3,4,5] }.to raise_error ArgumentError
    end

    it 'assigns the given teams to the starting seats of each round' do
      subject = described_class.new 4
      subject.seed [1,2,3,4]
      expect(subject.starting_seats_by_round(0).map(&:payload)).to eq [1,4,2,3]
      expect(subject.starting_seats_by_round(1).map(&:payload)).to eq [1,3,4,2]
      expect(subject.starting_seats_by_round(2).map(&:payload)).to eq [1,2,3,4]
    end

    it 'leaves remaining seats with a nil payload' do
      subject = described_class.new 4
      subject.seed [1,2,3]
      expect(subject.starting_seats.sort_by(&:position).map(&:payload)).to \
        eq [nil,3,1,2,nil,2,3,1,nil,1,2,3]
    end

    context 'when the return match should be played' do
      it 'assigns the given teams to the starting seats of each round' do
        subject = described_class.new 4, double_match: true
        subject.seed [1,2,3,4]
        expect(subject.starting_seats_by_round(0).map(&:payload)).to eq [1,4,2,3]
        expect(subject.starting_seats_by_round(1).map(&:payload)).to eq [1,3,4,2]
        expect(subject.starting_seats_by_round(2).map(&:payload)).to eq [1,2,3,4]
        # return matches
        expect(subject.starting_seats_by_round(3).map(&:payload)).to eq [4,1,3,2]
        expect(subject.starting_seats_by_round(4).map(&:payload)).to eq [3,1,2,4]
        expect(subject.starting_seats_by_round(5).map(&:payload)).to eq [2,1,4,3]
      end
    end
  end

  describe '#[]' do
    it 'return the seat with the given position' do
      subject = described_class.new 8
      expect(subject[6].position).to eq 6
    end
  end

  describe '#seats' do
    it 'returns seats' do
      subject = described_class.new 8
      expect(subject.seats.map(&:class).uniq).to eq [BracketGraph::Seat]
    end

    it 'returns all generated seats' do
      subject = described_class.new 8
      # starting_seats = 8 * (8-1) = 56
      # match = 8/2 * (8-1) = 28
      expect(subject.seats.count).to eq 84
    end
  end
end
