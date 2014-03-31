require 'spec_helper'

describe BracketGraph::Seat do
  let(:subject_class) { BracketGraph::Seat }

  describe 'constructor' do
    it 'accepts the destination' do
      expect(subject_class.new('a').to).to eq 'a'
    end

    it 'accepts the source' do
      expect(subject_class.new(nil,'b').from).to eq 'b'
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
end
