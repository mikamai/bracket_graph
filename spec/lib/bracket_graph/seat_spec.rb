require 'spec_helper'

describe BracketGraph::Seat do
  let(:subject_class) { BracketGraph::Seat }
  let(:subject) { subject_class.new 10 }

  describe 'constructor' do
    it 'raises error if position is nil' do
      expect { subject_class.new }.to raise_error
    end

    it 'requires position' do
      subject = subject_class.new 10
      expect(subject.position).to eq 10
    end

    it 'accepts the destination' do
      dest = subject_class.new 12
      expect(subject_class.new(10, dest).to).to eq dest
    end

    it 'allows the destination to not be set' do
      expect { subject_class.new 10 }.to_not raise_error
    end
  end

  describe '#create_children' do
    it 'fills the source' do
      expect { subject.create_children }.to change(subject, :from).to Array
    end

    it 'builds source using two seats' do
      expect(subject.create_children.map(&:class).uniq).to eq [BracketGraph::Seat]
    end

    it 'sets the current seat as destination for the built seats' do
      expect(subject.create_children.map(&:to).uniq).to eq [subject]
    end

    it 'raises an error if a source is already built' do
      subject.create_children
      expect { subject.create_children }.to raise_error NoMethodError
    end
  end

  describe '#depth' do
    it 'is 0 when the seat has no destination' do
      expect(subject_class.new(10).depth).to eq 0
    end

    it 'equals destination_depth + 1when destination is set' do
      destination = double depth: 10
      expect(subject_class.new(10, destination).depth).to eq 11
    end
  end

  describe '#round' do
    it 'returns 0 if seat has no source' do
      expect(subject_class.new(10).round).to be_zero
    end

    it 'returns source_round + 1 if a source exists' do
      subject.stub from: [double(round: 10), double(round: 10)]
      expect(subject.round).to eq 11
    end
  end

  describe 'marshalling' do
    it 'stores source and position' do
      subject = subject_class.new 10
      subject.instance_variable_set '@from', 'asd'
      expect(subject.marshal_dump).to eq position: 10, from: 'asd'
    end

    it 'restores position' do
      subject = subject_class.new 10
      expect { subject.marshal_load position: 1, from: nil }.to change(subject, :position).to 1
    end

    it 'restores source' do
      subject = subject_class.new 10
      source = [subject_class.new(8), subject_class.new(6)]
      expect { subject.marshal_load position: 1, from: source }.to change(subject, :from).to source
    end

    it 'restores source to' do
      subject = subject_class.new 10
      subject.create_children
      other = subject_class.new 10
      other.marshal_load subject.marshal_dump
      expect(other.from.map(&:to).uniq).to eq [other]
    end
  end

  describe '#to_json' do
    before { subject = subject_class.new 10 }

    it 'returns a json representation' do
      expect { JSON.parse subject.to_json }.to_not raise_error
    end

    it 'returns position' do
      expect(JSON.parse(subject.to_json)['position']).to eq 10
    end

    it 'returns source match' do
      subject.create_children
      expect(JSON.parse(subject.to_json).key? 'from').to be_true
    end

    it 'returns payload' do
      subject.payload = { id: 9 }
      expect(JSON.parse(subject.to_json)['payload']).to eq 'id' => 9
    end
  end
end
