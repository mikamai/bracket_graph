require 'spec_helper'
require 'active_support/core_ext'

describe BracketGraph::Graph do
  let!(:subject_class) { BracketGraph::Graph }

  describe 'constructor' do
    it 'creates instance with a certain size' do
      expect { subject_class.new 128 }.to_not raise_error
    end

    it 'raises error if size is not a power of 2' do
      expect { subject_class.new 3 }.to raise_error ArgumentError
    end

    it 'creates a root seat node' do
      subject = subject_class.new 4
      expect(subject.root).to be_a BracketGraph::Seat
    end

    it 'appends a match node to the root' do
      subject = subject_class.new 4
      expect(subject.root.from).to be_a BracketGraph::Match
    end

    it 'appends two seats as input in the root match node' do
      subject = subject_class.new 4
      expect(subject.root.from.from.map(&:class)).to eq [BracketGraph::Seat,BracketGraph::Seat]
    end

    it 'follows this pattern until the last level children count is equal to the graph size' do
      subject = subject_class.new 128
      nodes = 7.times.inject([subject.root]) do |current_nodes|
        current_nodes.inject([]) do |memo, node|
          from_match = node.from
          expect(from_match).to be_a BracketGraph::Match
          expect(from_match.from.count).to eq 2
          memo.concat from_match.from
        end
      end
      expect(nodes.count).to eq 128
      nodes.each { |node| expect(node.from).to be_nil }
    end

    it 'sets depths starting from 0' do
      subject = subject_class.new 128
      expect(subject.root.depth).to eq 0
    end

    it 'sets depths ending to log2 of size' do
      subject = subject_class.new 128
      expect(subject.starting_seats.map(&:depth).uniq).to eq [7]
    end

    it 'sets rounds starting from log2 of size' do
      subject = subject_class.new 128
      expect(subject.root.round).to eq 7
    end

    it 'sets rounds ending to 0' do
      subject = subject_class.new 128
      expect(subject.starting_seats.map(&:round).uniq).to eq [0]
    end

    it 'sets root position to size' do
      subject = subject_class.new 64
      expect(subject.root.position).to eq 64
    end

    it 'sets source seats (through the match) to size - (size / 2) and size + (size / 2)' do
      subject = subject_class.new 64
      children = subject.root.from.from
      expect(children.map(&:position).sort).to eq [32,96]
    end
  end

  describe '#starting_seats' do
    it 'returns a collection of the given size' do
      subject = subject_class.new 128
      expect(subject.starting_seats.count).to eq 128
    end

    it 'returns a collection of seats' do
      subject = subject_class.new 8
      expect(subject.starting_seats.map(&:class).uniq).to eq [BracketGraph::Seat]
    end

    it 'returns the last level seats' do
      subject = subject_class.new 8
      subject.starting_seats.each do |seat|
        expect(seat.from).to be_nil
      end
    end
  end

  describe '#seed' do
    it 'assigns the given teams to the starting seats' do
      subject = subject_class.new 4
      subject.seed [1,2,3,4]
      expect(subject.starting_seats.map(&:payload)).to match_array [1,2,3,4]
    end

    it 'does not change the given array' do
      subject = subject_class.new 4
      array = [1,2,3,4]
      expect { subject.seed array }.to_not change array, :count
    end

    it 'fills seats by position' do
      subject = subject_class.new 4
      subject.seed [1,2,3,4]
      expect(subject.starting_seats.sort_by(&:position).map(&:payload)).to eq [1,2,3,4]
    end

    it 'leaves remaining seats with a nil payload' do
      subject = subject_class.new 4
      subject.seed [1,2,3]
      expect(subject.starting_seats.sort_by(&:position).map(&:payload)).to eq [1,2,3,nil]
    end

    it 'calls #prepare_teams_for_seed' do
      subject = subject_class.new 4
      expect(subject).to receive(:prepare_teams_for_seed).with([1,2,3,4], shuffle: true).and_return []
      subject.seed [1,2,3,4], shuffle: true
    end
  end

  describe '#prepare_teams_for_seed' do
    it 'fills missing values with nils' do
      subject = subject_class.new 4
      expect(subject.send :prepare_teams_for_seed, [1,2]).to eq [1,2,nil,nil]
    end

    context 'when the shuffle option is set' do
      it 'shuffles the given collection' do
        subject = subject_class.new 4
        expect_any_instance_of(Array).to receive(:shuffle!)
        subject.send :prepare_teams_for_seed, [1,2,3,4], shuffle: true
      end
    end
  end
end
