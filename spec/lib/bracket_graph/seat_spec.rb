require 'spec_helper'

describe BracketGraph::Seat do
  let(:subject_class) { BracketGraph::Seat }

  describe 'constructor' do
    it 'accepts the destination' do
      match = BracketGraph::Match.new subject_class.new
      expect(subject_class.new(match).to).to eq match
    end

    it 'allows the destination to not be set' do
      expect { subject_class.new }.to_not raise_error
    end
  end

  describe 'build_input_match' do
    it 'fills the source' do
      expect { subject.build_input_match }.to change(subject, :from)
    end

    it 'sets a match as source' do
      expect(subject.build_input_match).to be_a BracketGraph::Match
    end

    it 'sets the current seat as destination for the built match' do
      expect(subject.build_input_match.winner_to).to eq subject
    end

    it 'raises an error if a source input match is present' do
      subject.build_input_match
      expect { subject.build_input_match }.to raise_error NoMethodError
    end
  end

  describe '#depth' do
    it 'is 0 when the seat has no destination' do
      expect(subject_class.new.depth).to eq 0
    end

    it 'equals destination_depth when destination is set' do
      destination = double depth: 10
      expect(subject_class.new(destination).depth).to eq 10
    end
  end

  describe '#round' do
    it 'returns 0 if seat has no source' do
      expect(subject_class.new.round).to be_zero
    end

    it 'returns source_round + 1 if a source exists' do
      subject.stub from: double(round: 10)
      expect(subject.round).to eq 11
    end
  end
end
