require 'spec_helper'

describe BracketGraph::Graph do
  describe 'constructor' do
    it 'creates instance with a certain size' do
      expect { described_class.new 128 }.to_not raise_error
    end

    it 'raises error if size is not a power of 2' do
      expect { described_class.new 3 }.to raise_error ArgumentError
    end

    it 'creates a root seat node' do
      subject = described_class.new 4
      expect(subject.root).to be_a BracketGraph::Seat
    end

    it 'appends two seats as input in the root match node' do
      subject = described_class.new 4
      expect(subject.root.from.map(&:class)).to eq [BracketGraph::Seat,BracketGraph::Seat]
    end

    it 'follows this pattern until the last level children count is equal to the graph size' do
      subject = described_class.new 128
      nodes = 7.times.inject([subject.root]) do |current_nodes|
        current_nodes.inject([]) do |memo, node|
          expect(node.from.count).to eq 2
          memo.concat node.from
        end
      end
      expect(nodes.count).to eq 128
      nodes.each { |node| expect(node.from).to be_empty }
    end

    it 'sets depths starting from 0' do
      subject = described_class.new 128
      expect(subject.root.depth).to eq 0
    end

    it 'sets depths ending to log2 of size' do
      subject = described_class.new 128
      expect(subject.starting_seats.map(&:depth).uniq).to eq [7]
    end

    it 'sets rounds starting from log2 of size' do
      subject = described_class.new 128
      expect(subject.root.round).to eq 7
    end

    it 'sets rounds ending to 0' do
      subject = described_class.new 128
      expect(subject.starting_seats.map(&:round).uniq).to eq [0]
    end

    it 'sets root position to size' do
      subject = described_class.new 64
      expect(subject.root.position).to eq 64
    end

    it 'sets source seats (through the match) to size - (size / 2) and size + (size / 2)' do
      subject = described_class.new 64
      children = subject.root.from
      expect(children.map(&:position).sort).to eq [32,96]
    end

    it 'does not duplicate positions' do
      subject = described_class.new 128
      expect(subject.seats.map(&:position).uniq.count).to eq subject.seats.count
    end

    it 'creates a graph given its root node' do
      existing = described_class.new 4
      subject = described_class.new existing.root
      expect(subject.starting_seats).to eq existing.starting_seats
    end

    it 'always sets the children by position order' do
      subject = described_class.new 32
      positions_groups = subject.seats.map { |s| s.from.map &:position }
      positions_groups.each do |position_group|
        expect(position_group).to eq position_group.sort
      end
    end

    context 'when a third and fourth match is needed' do
      subject { described_class.new 4, true }

      describe 'Graph#third_fourth_match' do
        let(:third_fourth_match) { subject.third_fourth_match }

        it 'is a seat' do
          expect(third_fourth_match).to be_a BracketGraph::Seat
        end

        it 'his position is the double of the size' do
          expect(third_fourth_match.position).to eq 8
        end

        it 'his rount is the same of the root' do
          expect(third_fourth_match.round).to eq subject.root.round
        end

        it 'is included in the list of the seats' do
          expect(subject.seats).to include third_fourth_match
        end

        describe '.childrens' do
          let(:childrens) { third_fourth_match.from }

          it 'are 2' do
            expect(childrens.size).to eq 2
          end

          it 'are starting seats' do
            expect(childrens.map(&:from)).to eq [[],[]]
          end

          it 'their positions are based on the parent' do
            parent_position = third_fourth_match.position
            expect(childrens.map(&:position)).to eq [1,2].map { |i| parent_position + i  }
          end

          it 'their rounds are the same of the parent' do
            parent_round = third_fourth_match.round
            expect(childrens.map(&:round).uniq.first).to eq parent_round
          end

          it 'are setted as loser_to of the semi-finals' do
            expect(subject.root.from.map(&:loser_to)).to match childrens
          end

          it 'are included in the list of the seats' do
            childrens.map(&:position).each do |children|
              expect(subject.seats.map(&:position)).to include children
            end
          end

          it 'are not included in the list of the starting_seats' do
            childrens.map(&:position).each do |children|
              expect(subject.starting_seats.map(&:position)).to_not include children
            end
          end
        end
      end
    end
  end

  describe '#starting_seats' do
    it 'returns a collection of the given size' do
      subject = described_class.new 128
      expect(subject.starting_seats.count).to eq 128
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

    it 'assigns the given teams to the starting seats' do
      subject = described_class.new 4
      subject.seed [1,2,3,4]
      expect(subject.starting_seats.map(&:payload)).to match_array [1,2,3,4]
    end

    it 'does not change the given array' do
      subject = described_class.new 4
      array = [1,2,3,4]
      expect { subject.seed array }.to_not change array, :count
    end

    it 'fills seats by position' do
      subject = described_class.new 4
      subject.seed [1,2,3,4]
      expect(subject.starting_seats.sort_by(&:position).map(&:payload)).to eq [1,2,3,4]
    end

    it 'leaves remaining seats with a nil payload' do
      subject = described_class.new 4
      subject.seed [1,2,3]
      expect(subject.starting_seats.sort_by(&:position).map(&:payload)).to eq [nil,1,2,3]
    end

    it 'uses the TeamSeeder' do
      subject = described_class.new 4
      expect_any_instance_of(TeamSeeder).to receive(:slots).and_return []
      subject.seed [1,2,3,4], shuffle: true
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
      expect(subject.seats.count).to eq 15
    end

    it 'returns the root node too' do
      subject = described_class.new 8
      expect(subject.seats).to include subject.root
    end
  end
end
