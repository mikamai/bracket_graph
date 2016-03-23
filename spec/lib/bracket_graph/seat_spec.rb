require 'spec_helper'

describe BracketGraph::Seat do
  let(:subject_class) { BracketGraph::Seat }
  let(:subject) { subject_class.new 10 }

  describe 'constructor' do
    it 'raises error if position is nil' do
      expect { subject_class.new }.to raise_error ArgumentError
    end

    it 'requires position' do
      subject = subject_class.new 10
      expect(subject.position).to eq 10
    end

    it 'accepts the destination' do
      dest = subject_class.new 12
      expect(subject_class.new(10, to: dest).to).to eq dest
    end

    it 'allows the destination to not be set' do
      expect { subject_class.new 10 }.to_not raise_error
    end
  end

  describe '#depth' do
    it 'is 0 when the seat has no destination' do
      expect(subject_class.new(10).depth).to eq 0
    end

    it 'equals destination_depth + 1when destination is set' do
      destination = double 11, depth: 10, round: 9
      expect(subject_class.new(10, to: destination).depth).to eq 11
    end
  end

  describe '#round' do
    it 'returns 0 if seat has no source' do
      expect(subject_class.new(10).round).to be_zero
    end

    it 'returns parent round - 1 if a parent exists' do
      allow(subject).to receive(:to) { double(round: 10) }
      expect(subject.round).to eq 9
    end
  end

  describe 'marshalling' do
    it 'stores source, position and round' do
      subject = subject_class.new 10, round: 10
      subject.instance_variable_set '@from', ['asd']
      expect(subject.marshal_dump).to eq position: 10, from: ['asd'], round: 10
    end

    it 'restores position' do
      subject = subject_class.new 10, round: 10
      expect { subject.marshal_load position: 1, from: nil }.to change(subject, :position).to 1
    end

    it 'restores source' do
      subject = subject_class.new 10, round: 10
      source = [subject_class.new(8), subject_class.new(6)]
      expect { subject.marshal_load position: 1, from: source }.to change(subject, :from).to source
    end

    it 'restores source to' do
      subject = described_class.new 10, round: 10
      subject.from[0] = described_class.new 11, to: subject
      other = described_class.new 10
      other.marshal_load subject.marshal_dump
      expect(other.from.map(&:to)).to eq [other]
    end
  end

  describe '#as_json' do
    subject { described_class.new 10, round: 10 }

    it 'returns a json representation' do
      expect { subject.as_json }.to_not raise_error
    end

    it 'returns position' do
      expect(subject.as_json[:position]).to eq 10
    end

    it 'returns source matches' do
      subject.from[0] = described_class.new 11, to: subject
      expect(subject.as_json.key? :from).to be_truthy
    end

    it 'returns payload' do
      subject.payload = { id: 9 }
      expect(subject.as_json[:payload]).to eq :id => 9
    end
  end

  describe '#starting?' do
    subject { described_class.new 10, round: 10 }

    it 'returns true if there are no children' do
      expect(subject).to be_starting
    end

    it 'returns false if there are children' do
      subject.from << double
      expect(subject).not_to be_starting
    end

    it 'returns true if #from is nil' do
      subject.instance_variable_set '@from', nil
      expect(subject).to be_starting
    end
  end

  describe '#final?' do
    subject { described_class.new 10, round: 10 }

    it 'returns true if there is no parent seat' do
      expect(subject).to be_final
    end

    it 'returns false if there is a parent seat' do
      subject.to = double
      expect(subject).not_to be_final
    end
  end
end
