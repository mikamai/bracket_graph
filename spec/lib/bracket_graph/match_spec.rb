require 'spec_helper'

describe BracketGraph::Match do
  let(:subject_class) { BracketGraph::Match }

  describe 'constructor' do
    it 'accepts a winner destination' do
      expect(subject_class.new('asd').winner_to).to eq 'asd'
    end

    it 'accepts a source array' do
      expect(subject_class.new(nil,['a','b']).from).to eq ['a','b']
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
end
