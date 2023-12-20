require 'pry-byebug'
require 'spec_helper.rb'

require './a.rb'

describe 'find_next_strings' do
  context 'single needs_word, current word needing more' do
    it { expect(find_next_strings('' , [1])).to eq [ ['.',  [1]],
                                                     ['#',  [0]] ] }
    it { expect(find_next_strings('.', [2])).to eq [ ['..', [2]],
                                                     ['.#', [1]] ] }
    it { expect(find_next_strings('#', [2])).to eq [ ['##', [1]] ] }
    it { expect(find_next_strings('..##..##..##', [3])).to eq [ ['..##..##..###', [2]] ] }
  end

  context 'multi needs_word, current word needing more' do
    it { expect(find_next_strings('' , [1, 3])).to eq [ ['.',  [1, 3]],
                                                        ['#',  [0, 3]] ] }
    it { expect(find_next_strings('.', [2, 3])).to eq [ ['..', [2, 3]],
                                                        ['.#', [1, 3]] ] }
    it { expect(find_next_strings('#', [2, 3])).to eq [ ['##', [1, 3]] ] }
  end

  context 'single needs_word, current word satisfied' do
    it { expect(find_next_strings('#' , [0, 3])).to eq [ ['#.' , [0, 3]] ] }
    it { expect(find_next_strings('#.', [0, 3])).to eq [ ['#..',  [0, 3]],
                                                         ['#.#',  [2]] ] }
  end

  context 'possibly successful solution (no more words needed)' do
    it { expect(find_next_strings('.##' , [0])).to eq [ [".##.", [0]] ] }
    it { expect(find_next_strings('.##.', [0])).to eq [ [".##..", [0]] ] }
  end

end

describe 'check_solution(src, word_needs, str)' do
  subject(:call) { check_solution(src, word_needs, str) }
  let(:src) { '#' }
  let(:word_needs) { [1] }
  let(:str) { '#' }

  context 'static successes' do
    it { expect(check_solution('#', [0], '#')).to eq :COMPLETE }
    it { expect(check_solution('.#', [0], '.#')).to eq :COMPLETE }
    it { expect(check_solution('#.', [0], '#.')).to eq :COMPLETE }
    it { expect(check_solution('.#.', [0], '.#.')).to eq :COMPLETE }
    it { expect(check_solution('#......', [0], '#......')).to eq :COMPLETE }
    it { expect(check_solution('...#...', [0], '...#...')).to eq :COMPLETE }
    it { expect(check_solution('......#', [0], '......#')).to eq :COMPLETE }
    it { expect(check_solution('##', [0], '##')).to eq :COMPLETE }
    it { expect(check_solution('#.#', [0], '#.#')).to eq :COMPLETE }
    it { expect(check_solution('.##..###.', [0], '.##..###.')).to eq :COMPLETE }
  end

  context 'static non-success' do
    it { expect(check_solution('#', [1], '')).to eq :GO_ON }
    it { expect(check_solution('#', [1], '##')).to eq :TOO_LONG }
    it { expect(check_solution('#', [1], '#.')).to eq :TOO_LONG }
    it { expect(check_solution('#.....', [1], '.#')).to eq :BAD_PATTERN }
    # it { expect(check_solution('#', [2], '#')).to eq :FAILED_NEEDS } # maybe
    it { expect(check_solution('#', [2], '#')).to eq :GO_ON } # to be caught by a later failure.
    it { expect(check_solution('#...', [1], '##')).to eq :BAD_PATTERN }
  end

  context 'wildcard successes' do
    it { expect(check_solution('?', [0], '#')).to eq :COMPLETE }
    it { expect(check_solution('.?', [0], '.#')).to eq :COMPLETE }
    it { expect(check_solution('?.', [0], '#.')).to eq :COMPLETE }
    it { expect(check_solution('??', [0], '.#')).to eq :COMPLETE }
    it { expect(check_solution('??', [0], '#.')).to eq :COMPLETE }
    it { expect(check_solution('??', [0], '##')).to eq :COMPLETE }
    it { expect(check_solution('..??..??..', [0], '...#..#...')).to eq :COMPLETE }
    it { expect(check_solution('..??..??..', [0], '..##..##..')).to eq :COMPLETE }
  end

  context 'wildcard non-successes' do
    it { expect(check_solution('?', [1], '')).to eq :GO_ON }
    # it { expect(check_solution('?', [2], '#')).to eq :FAILED_NEEDS } # maybe?
    it { expect(check_solution('?', [2], '#')).to eq :GO_ON } # to be caught by a later failure.
    # it { expect(check_solution('.?', [2], '.#')).to eq :FAILED_NEEDS } # maybe?
    it { expect(check_solution('?.', [2], '#.')).to eq :GO_ON } # to be caught by a later failure.
    # it { expect(check_solution('?.', [2], '#.')).to eq :FAILED_NEEDS } # maybe?
    it { expect(check_solution('??', [2], '#')).to eq :GO_ON }
    # it { expect(check_solution('??', [2], '.#')).to eq :FAILED_NEEDS } # maybe?
    it { expect(check_solution('??', [2], '.#')).to eq :GO_ON } # to be caught by a later failure.
    # it { expect(check_solution('??', [2], '..')).to eq :FAILED_NEEDS } # maybe?
    it { expect(check_solution('??', [2], '..')).to eq :GO_ON } # to be caught by a later failure.
    # it { expect(check_solution('????', [1], '##')).to eq :TOO_WORDY } # maybe?
    it { expect(check_solution('????', [1], '##')).to eq :GO_ON } # to be caught by a later failure.
  end
end

describe 'solutions' do

  # # Don't need to handle edge cases:
  # Record.new('', '').expect_solution(1)
  # Record.new('', '1').expect_solution(0)
  # Record.new('.', '').expect_solution(1)

  context 'Simple, undamaged records' do
    it { expect(solutions('#', [1])).to eq 1 }
    it { expect(solutions('.#', [1])).to eq 1 }
    it { expect(solutions('#.', [1])).to eq 1 }
    it { expect(solutions('.#.', [1])).to eq 1 }

    it { expect(solutions('##', [2])).to eq 1 }
    it { expect(solutions('.##.', [2])).to eq 1 }
    it { expect(solutions('#.#', [1,1])).to eq 1 }
    it { expect(solutions('#.#.', [1,1])).to eq 1 }
    it { expect(solutions('#.##', [1,2])).to eq 1 }
    it { expect(solutions('.##.....#', [2,1])).to eq 1 }
    it { expect(solutions('.##......', [2])).to eq 1 }
    it { expect(solutions('.##.###..', [2,3])).to eq 1 }
    it { expect(solutions('.##.###.#', [2,3,1])).to eq 1 }

    # it { expect(solutions('#', [2])).to eq 0 }
    # it { expect(solutions('.#', [2])).to eq 0 }
    # it { expect(solutions('#.', [2])).to eq 0 }
    # it { expect(solutions('.#.', [2])).to eq 0 }

    # it { expect(solutions('..##.###.#', [2,3,1])).to eq 1 }
    # it { expect(solutions('..##.###..#', [2,3,1])).to eq 1 }
    # it { expect(solutions('..##.###.#.', [2,3,1])).to eq 1 }
    # it { expect(solutions('..##.###..#.', [2,3,1])).to eq 1 }
  end

  context 'Wildcard, damaged records' do
    it { expect(solutions('?', [1])).to eq 1 }
    it { expect(solutions('?#', [2])).to eq 1 }
    it { expect(solutions('#?', [2])).to eq 1 }
    it { expect(solutions('.??.', [1])).to eq 2 }
    it { expect(solutions('.??.??.', [1,2])).to eq 2 }
    it { expect(solutions('.??.??.', [1,1])).to eq 4 }

    # it { expect(solutions('##', [2])).to eq 1 }
    # it { expect(solutions('.##.', [2])).to eq 1 }
    # it { expect(solutions('#.#', [1,1])).to eq 1 }
    # it { expect(solutions('.##.....#', [2,1])).to eq 1 }
    # it { expect(solutions('.##.###.#', [2,3,1])).to eq 1 }

    # it { expect(solutions('#', [2])).to eq 0 }
    # it { expect(solutions('.#', [2])).to eq 0 }
    # it { expect(solutions('#.', [2])).to eq 0 }
    # it { expect(solutions('.#.', [2])).to eq 0 }

    # it { expect(solutions('..##.###.#', [2,3,1])).to eq 1 }
    # it { expect(solutions('..##.###..#', [2,3,1])).to eq 1 }
    # it { expect(solutions('..##.###.#.', [2,3,1])).to eq 1 }
    # it { expect(solutions('..##.###..#.', [2,3,1])).to eq 1 }
  end

  # # With gaps in word_needs:
  # Record.new('#.##', '1,2').expect_solution(1)
  # Record.new('#..##', '1,2').expect_solution(1)
  # Record.new('#..##', '1,3').expect_solution(0)
  # Record.new('#..##...#..###...', '1,2,1,3').expect_solution(1)

  # # with damaged records:
  # Record.new('?', '1').expect_solution(1)
  # Record.new('???', '1').expect_solution(3)
  # Record.new('#?', '1').expect_solution(1)
  # Record.new('?#', '1').expect_solution(1)
  # Record.new('?##', '3').expect_solution(1)
  # Record.new('#?', '2').expect_solution(1)
  # Record.new('.##?...', '3').expect_solution(1)

  # Record.new('.???', '2').expect_solution(2)
  # Record.new('.???.', '1').expect_solution(3)
  # Record.new('#??', '1,1').expect_solution(1)
  # Record.new('???', '1,1').expect_solution(1)
  # Record.new('.?.?.', '1,1').expect_solution(1)
  # Record.new('.??.?.', '1,1').expect_solution(2)
  # Record.new('.?.??.', '1,1').expect_solution(2)
  # Record.new('???.???', '1,2').expect_solution(6)


  # Record.new('???', '1,1').expect_solution(1)
  # Record.new('?###????????', '3,2,1').expect_solution(10)

end