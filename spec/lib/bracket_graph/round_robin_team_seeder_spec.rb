require 'spec_helper'

describe RoundRobinTeamSeeder do
  describe '#rotate_slots' do
    subject { described_class.new [1,2,3,4], 4, shuffle: false }

    before { allow(subject).to receive(:random_rotation).and_return 2 }

    it 'return the slots rotate with the rr algorithm and rotate again to shuffle the position' do
      expect(subject.rotate_slots).to eq [4,2,1,3]
    end

    it 'the original value of slots follows only the rr algorithm' do
      subject.rotate_slots
      expect(subject.slots).to eq [1,4,2,3]
      subject.rotate_slots
      expect(subject.slots).to eq [1,3,4,2]
    end

    1.upto(16).map{ |i| i * 2 }.each do |size|
      it "never returns the same opponent pair with a size of #{size}" do
        subject = described_class.new (1..size).to_a, size, shuffle: false
        slots = [].tap do |s|
          (size-1).times{ s << subject.rotate_slots }
        end
        pairs = []
        slots.each do |slot|
          slot.each_slice(2).each { |pair| pairs << pair.sort }
        end
        expect(pairs.uniq.size).to eq (size-1) * size/2
      end
    end
  end
end
