require 'spec_helper'
require 'active_support/core_ext'

describe BracketGraph::Graph do
  let!(:subject_class) { BracketGraph::Graph }

  describe 'constructor' do
    it 'creates instance with a certain size' do
      expect { subject_class.new 128 }.to_not raise_error
    end

    it 'raises error if size is not a power of 2' do
      expect { subject_class.new 3 }.to raise_error ArgumentError
    end

    it 'creates a root seat node' do
      subject = subject_class.new 4
      expect(subject.root).to be_a BracketGraph::Seat
    end

    it 'appends a match node to the root' do
      subject = subject_class.new 4
      expect(subject.root.from).to be_a BracketGraph::Match
    end

    it 'appends two seats as input in the root match node' do
      subject = subject_class.new 4
      expect(subject.root.from.from.map(&:class)).to eq [BracketGraph::Seat,BracketGraph::Seat]
    end

    it 'follows this pattern until the last level children count is equal to the graph size' do
      subject = subject_class.new 128
      nodes = 7.times.inject([subject.root]) do |current_nodes|
        current_nodes.inject([]) do |memo, node|
          from_match = node.from
          expect(from_match).to be_a BracketGraph::Match
          expect(from_match.from.count).to eq 2
          memo.concat from_match.from
        end
      end
      expect(nodes.count).to eq 128
      nodes.each { |node| expect(node.from).to be_nil }
    end
  end
end
