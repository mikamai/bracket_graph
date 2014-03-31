require 'spec_helper'

describe BracketGraph::Match do
  let(:subject_class) { BracketGraph::Match }
  let(:subject) { subject_class.new BracketGraph::Seat.new }

  describe 'constructor' do
    it 'requires the winner destination' do
      expect { subject_class.new }.to raise_error ArgumentError
    end

    it 'sets the winner destination' do
      node = BracketGraph::Seat.new
      expect(subject_class.new(node).winner_to).to eq node
    end

    it 'accepts a source array' do
      expect(subject_class.new(BracketGraph::Seat.new,['a','b']).from).to eq ['a','b']
    end

    it 'raises an error if source is not an array' do
      expect { subject_class.new nil, 'asd' }.to raise_error ArgumentError
    end
  end

  describe '#build_input_seats' do
    it 'fills source seats with two items' do
      expect(subject.build_input_seats.count).to eq 2
    end

    it 'fills source seats with seats objects' do
      expect(subject.build_input_seats.map(&:class).uniq).to eq [BracketGraph::Seat]
    end

    it 'sets the current match as the destination of the built seats' do
      expect(subject.build_input_seats.map(&:to).uniq).to eq [subject]
    end
  end

  describe '#depth' do
    it 'equals to destination_depth + 1' do
      subject = subject_class.new double depth: 10
      expect(subject.depth).to eq 11
    end
  end
end
