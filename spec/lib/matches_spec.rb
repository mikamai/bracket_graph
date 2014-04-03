require 'spec_helper'

describe BracketGraph::Matches do
  describe '#in_round' do
    it 'returns items in the given round' do
      subject << double(round: 10)
      subject << double(round: 1)
      expect(subject.in_round(1).count).to eq 1
    end
  end
end