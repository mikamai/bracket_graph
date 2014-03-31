require 'spec_helper'

describe BracketGraph::Match do
  let(:subject_class) { BracketGraph::Match }
  let(:subject) { subject_class.new BracketGraph::Seat.new 12 }

  describe 'constructor' do
    it 'requires the winner destination' do
      expect { subject_class.new }.to raise_error ArgumentError
    end

    it 'sets the winner destination' do
      node = BracketGraph::Seat.new 12
      expect(subject_class.new(node).winner_to).to eq node
    end

    it 'fills source seats with two items' do
      expect(subject.from.count).to eq 2
    end

    it 'fills source seats with seats objects' do
      expect(subject.from.map(&:class).uniq).to eq [BracketGraph::Seat]
    end

    it 'sets the current match as the destination of the built seats' do
      expect(subject.from.map(&:to).uniq).to eq [subject]
    end

    it 'creates the children giving the correct depth info' do
      expect(subject.from.map(&:depth).uniq).to eq [1]
    end

    it 'sets (winner_to_position - (winner_to_position / 2)) to the first child' do
      subject = subject_class.new BracketGraph::Seat.new 12
      expect(subject.from.first.position).to eq 6
    end

    it 'sets (winner_to_position + (winner_to_position / 2)) to the first child' do
      subject = subject_class.new BracketGraph::Seat.new 12
      expect(subject.from.last.position).to eq 18
    end
  end

  describe '#depth' do
    it 'equals to destination_depth + 1' do
      subject = subject_class.new double depth: 10, position: 10
      expect(subject.depth).to eq 11
    end
  end

  describe '#round' do
    it 'equals to the first source item round' do
      subject.stub from: [double(round: 10)]
      expect(subject.round).to eq 10
    end
  end

  describe '#winner' do
    it 'returns nil if match has not been played' do
      expect(subject.winner).to be_nil
    end
  end

  describe '#loser' do
    it 'returns nil if match has not been played' do
      expect(subject.loser).to be_nil
    end
  end

  describe '#winner=' do
    it 'requires a seat' do
      expect { subject.winner = 'asd' }.to raise_error ArgumentError
    end

    it 'requires one of the children' do
      expect { subject.winner = BracketGraph::Seat.new 10 }.to raise_error ArgumentError
    end

    it 'assigns the winner' do
      expect { subject.winner = subject.from.first }.to change(subject, :winner).to subject.from.first
    end

    it 'assigns the loser' do
      expect { subject.winner = subject.from.first }.to change(subject, :loser).to subject.from.last
    end

    it 'copies the winner payload to the winner destination seat' do
      subject.from.first.payload = 'asd'
      expect { subject.winner = subject.from.first }.to change(subject.winner_to, :payload).to 'asd'
    end
  end

  describe '#loser=' do
    it 'requires a seat' do
      expect { subject.loser = 'asd' }.to raise_error ArgumentError
    end

    it 'requires one of the children' do
      expect { subject.loser = BracketGraph::Seat.new 10 }.to raise_error ArgumentError
    end

    it 'assigns the winner' do
      expect { subject.loser = subject.from.first }.to change(subject, :winner).to subject.from.last
    end

    it 'assigns the loser' do
      expect { subject.loser = subject.from.first }.to change(subject, :loser).to subject.from.first
    end

    it 'copies the winner payload to the winner destination seat' do
      subject.from.first.payload = 'asd'
      expect { subject.loser = subject.from.last }.to change(subject.winner_to, :payload).to 'asd'
    end
  end

  describe 'marshalling' do
    it 'stores sources' do
      expect(subject.marshal_dump[:from].count).to eq 2
    end

    context 'when the match has been played' do
      it 'stores winner position' do
        subject.winner = subject.from.first
        expect(subject.marshal_dump[:winner]).to eq subject.from.first.position
      end
    end

    context 'when the match has not been played' do
      it 'stores winner to nil' do
        expect(subject.marshal_dump[:winner]).to be_nil
      end
    end

    it 'loads sources' do
      other = subject_class.new BracketGraph::Seat.new 10
      other.marshal_load subject.marshal_dump
      expect(other.from.map(&:position)).to eq subject.from.map(&:position)
    end

    it 'updates the to reference' do
      other = subject_class.new BracketGraph::Seat.new 10
      other.marshal_load subject.marshal_dump
      expect(other.from.map(&:to).uniq).to eq [other]
    end

    context 'if winner is set' do
      before { subject.winner = subject.from.first }

      it 'loads the winner object' do
        other = subject_class.new BracketGraph::Seat.new 10
        other.marshal_load subject.marshal_dump
        expect(other.winner).to eq other.from.first
      end
    end

    context 'if winner is nil' do
      it 'does not load the winner object' do
        other = subject_class.new BracketGraph::Seat.new 10
        other.marshal_load subject.marshal_dump
        expect(other.winner).to be_nil
      end
    end
  end

  describe '#to_json' do
    it 'returns a json representation' do
      expect { JSON.parse subject.to_json }.to_not raise_error
    end

    it 'returns source seats' do
      expect(JSON.parse(subject.to_json)['from'].count).to eq 2
    end

    it 'returns winner flag' do
      subject.winner = subject.from.first
      expect(JSON.parse(subject.to_json).key? 'winner').to be_true
    end
  end
end
