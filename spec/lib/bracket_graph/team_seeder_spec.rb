require 'spec_helper'

describe TeamSeeder do
  it 'shuffles teams if shuffle is true' do
    subject = TeamSeeder.new ['a','b','c'], 4, shuffle: true
    teams = subject.instance_variable_get '@teams'
    expect(teams).to_not eq ['a','b','c']
  end

  it 'does not shuffle teams if shuffle is false' do
    subject = TeamSeeder.new ['a','b','c'], 4
    teams = subject.instance_variable_get '@teams'
    expect(teams).to eq ['a','b','c']
  end

  describe '#slots' do
    let(:teams) { %w(a b c d e f g h i j k l m) }
    subject { TeamSeeder.new teams, 16 }

    it 'returns an array' do
      expect(subject.slots).to be_a Array
    end

    it 'returns an array of {slots} length' do
      expect(subject.slots.length).to eq 16
    end

    it 'inserts {slots} - {teams} byes' do
      expect(subject.slots.select(&:nil?).count).to eq 3
    end

    it 'inserts the first bye at the first position' do
      expect(subject.slots[0]).to be_nil
    end

    it 'inserts byes using the mid point of the large partition recursively' do
      expect(subject.slots).to eq [nil, 'a', 'b', 'c', nil, 'd', 'e', 'f', nil,
                                  'g', 'h', 'i', 'j', 'k', 'l', 'm']
    end
  end
end
