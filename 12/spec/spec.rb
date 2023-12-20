require './a.rb'
require 'pry'
require 'spec_helper.rb'

describe 'check_solution(src, word_needs, str)' do
  subject(:call) { check_solution(src, word_needs, str) }
  let(:src) { '#' }
  let(:word_needs) { [1] }
  let(:str) { '#' }


  context 'static successes' do
    it { expect(check_solution('#', [1], '#')).to eq :COMPLETE }
    it { expect(check_solution('.#', [1], '.#')).to eq :COMPLETE }
    it { expect(check_solution('#.', [1], '#.')).to eq :COMPLETE }
    it { expect(check_solution('.#.', [1], '.#.')).to eq :COMPLETE }
    it { expect(check_solution('#......', [1], '#......')).to eq :COMPLETE }
    it { expect(check_solution('...#...', [1], '...#...')).to eq :COMPLETE }
    it { expect(check_solution('......#', [1], '......#')).to eq :COMPLETE }
    it { expect(check_solution('##', [2], '##')).to eq :COMPLETE }
    it { expect(check_solution('#.#', [1,1], '#.#')).to eq :COMPLETE }
    it { expect(check_solution('.##..###.', [2,3], '.##..###.')).to eq :COMPLETE }
  end

  context 'static non-success' do
    it { expect(check_solution('#', [1], '')).to eq :GO_ON }
    it { expect(check_solution('#', [1], '##')).to eq :TOO_LONG }
    it { expect(check_solution('#.....', [1], '.#')).to eq :BAD_PATTERN }
    it { expect(check_solution('#', [2], '#')).to eq :FAILED_NEEDS }
    it { expect(check_solution('#...', [1], '##')).to eq :TOO_WORDY }

  end

  context 'wildcard successes' do
    it { expect(check_solution('?', [1], '#')).to eq :COMPLETE }
    it { expect(check_solution('.?', [1], '.#')).to eq :COMPLETE }
    it { expect(check_solution('?.', [1], '#.')).to eq :COMPLETE }
    it { expect(check_solution('??', [1], '.#')).to eq :COMPLETE }
    it { expect(check_solution('??', [1], '#.')).to eq :COMPLETE }
    it { expect(check_solution('??', [2], '##')).to eq :COMPLETE }
    it { expect(check_solution('..??..??..', [1,1], '...#..#...')).to eq :COMPLETE }
    it { expect(check_solution('..??..??..', [2,2], '..##..##..')).to eq :COMPLETE }
  end

  context 'wildcard non-successes' do
    it { expect(check_solution('?', [1], '')).to eq :GO_ON }
    it { expect(check_solution('?', [2], '#')).to eq :FAILED_NEEDS }
    it { expect(check_solution('.?', [2], '.#')).to eq :FAILED_NEEDS }
    it { expect(check_solution('?.', [2], '#.')).to eq :FAILED_NEEDS }
    it { expect(check_solution('??', [2], '#')).to eq :GO_ON }
    it { expect(check_solution('??', [2], '.#')).to eq :FAILED_NEEDS }
    it { expect(check_solution('??', [2], '..')).to eq :FAILED_NEEDS }
    it { expect(check_solution('????', [1], '##')).to eq :TOO_WORDY }

  end
end
