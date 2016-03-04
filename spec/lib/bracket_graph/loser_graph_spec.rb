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

    it 'sets root position to 1' do
      subject = described_class.new 64
      expect(subject.root.position).to eq 1
    end

    it 'sets the position of root children to 2 and 3' do
      subject = described_class.new 64
      expect(subject.root.from.map(&:position)).to match_array [2,3]
    end

    it 'sets source seats (through the match) to 4 and 5' do
      subject = described_class.new 64
      children = subject.root.from[1].from
      expect(children.map(&:position).sort).to eq [4, 5]
    end

    it 'does not duplicate positions' do
      subject = described_class.new 16
      expect(subject.seats.map(&:position).uniq.count).to eq subject.seats.count
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
  #
  # describe '#seed' do
  #   it 'raises error if there are more teams than starting seats' do
  #     subject = described_class.new 4
  #     expect { subject.seed [1,2,3,4,5] }.to raise_error ArgumentError
  #   end
  #
  #   it 'assigns the given teams to the starting seats' do
  #     subject = described_class.new 4
  #     subject.seed [1,2,3,4]
  #     expect(subject.starting_seats.map(&:payload)).to match_array [1,2,3,4]
  #   end
  #
  #   it 'does not change the given array' do
  #     subject = described_class.new 4
  #     array = [1,2,3,4]
  #     expect { subject.seed array }.to_not change array, :count
  #   end
  #
  #   it 'fills seats by position' do
  #     subject = described_class.new 4
  #     subject.seed [1,2,3,4]
  #     expect(subject.starting_seats.sort_by(&:position).map(&:payload)).to eq [1,2,3,4]
  #   end
  #
  #   it 'leaves remaining seats with a nil payload' do
  #     subject = described_class.new 4
  #     subject.seed [1,2,3]
  #     expect(subject.starting_seats.sort_by(&:position).map(&:payload)).to eq [nil,1,2,3]
  #   end
  #
  #   it 'uses the TeamSeeder' do
  #     subject = described_class.new 4
  #     expect_any_instance_of(TeamSeeder).to receive(:slots).and_return []
  #     subject.seed [1,2,3,4], shuffle: true
  #   end
  # end

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
      expect(subject.seats.count).to eq 13
    end

    it 'returns the root node too' do
      subject = described_class.new 8
      expect(subject.seats).to include subject.root
    end
  end

  describe '#marshal_dump' do
    it 'returns the root node' do
      subject = described_class.new 8
      expect(subject.marshal_dump).to eq subject.root
    end
  end

  describe '#marshal_load' do
    it 'requires the root node' do
      subject = described_class.new 8
      other = described_class.new 4
      expect { other.marshal_load subject.root }.to change(other, :root).to subject.root
    end

    it 'updates all references' do
      subject = described_class.new 8
      other = described_class.new 4
      expect { other.marshal_load subject.root }.to change(other, :seats)
    end
  end
end
