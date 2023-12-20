

# Returns the number of solutions to the input
# pattern remains the same throughout,
# but word_needs gets reduced through successive calls.
# and str builds up to the same length as pattern.
def solutions(pattern, word_needs, str = '')
  puts "solutions('#{pattern}', #{word_needs}, '#{str}')"

  action = check_solution(pattern, word_needs, str)

  case action
  when :GO_ON
    puts "   GO_ON: #{str}"
    poss =  find_next_strings(str, word_needs)
    return poss.sum do |longer_str, word_needs|
      solutions(pattern, word_needs, longer_str)
        # .tap  {|n| puts "      found #{n} sub-solutions"}
    end
  when :COMPLETE
    puts "COMPLETE: #{str}"
    return 1
  else
    puts "    HALT: #{str} (#{action})"
    return 0
  end
end

# Looks for reasons to stop processing.
# Returns GO_ON if no reason found, and str can continue to be built up.
# Returns COMPLETE if this is a completely correct end solution.
# Returns any other code to indicate why this str is not viable.
def check_solution(pattern, word_needs, str)
  puts "    check_solution('#{pattern}', word_needs, '#{str}')"
  return :TOO_LONG     if str.size > pattern.size

  # # this could go in check_needs:
  # char_count = str.count('#')
  # need_count = word_needs.sum
  # puts "char_count=#{char_count} need_count=#{need_count}"
  # return :TOO_WORDY    if char_count > need_count

  return :BAD_PATTERN  if !pattern_match?(pattern, str)

  need_stat = check_needs(word_needs, str, str.size == pattern.size)
  # puts "      need_stat=#{need_stat}"
  return :FAILED_NEEDS if need_stat == :FAILED_NEEDS
  return :COMPLETE     if need_stat == :COMPLETE && str.size == pattern.size
  return :GO_ON        if need_stat == :GO_ON


  return :GO_ON        if str.size < pattern.size

  # return :COMPLETE     if need_stat == :COMPLETE
  # return :COMPLETE     if str.size == pattern.size ## This may be too weak.

  # To do: Find many more ways to strike down INVALID attempts early on.

  raise "Should never get this far. What happened?"
end

# Only checks through str. string may become invalid when it grows longer.
def pattern_match?(pattern, str)
  str.chars.zip(pattern.chars).all? do |s, p|
    # puts "patern_match(#{p}, #{s})"
    p == s || p=='?'
  end
end

# Only checks all of current str. string may become invalid when it grows longer.
# if exact_match, then the needs must be exact_match, exactly met.
def check_needs(word_needs, str, exact_match)
  puts "check_needs?(#{word_needs}, '#{str}', #{exact_match})"
  # binding.pry

  word_lengths = str.split('.').map(&:length).select(&:positive?)

  puts "    // word_lengths=#{word_lengths} word_needs:#{word_needs}"
  # puts "  GO_ON? (!exact_match)"
  return :GO_ON if word_lengths.empty? && !exact_match

  latest_word_index = word_lengths.count - 1
  # puts "  latest_word_index: #{latest_word_index}"

  # puts "  complete?"
  return :COMPLETE if exact_match && word_needs == [0]
  # return :COMPLETE if exact_match && word_lengths == word_needs

  # puts "  FAILED_NEEDS? (exact)"

  # return :FAILED_NEEDS if exact_match && word_lengths != word_needs

  # puts "  FAILED_NEEDS? (so far)"

  # puts " (word_lengths[latest_word_index] > word_needs[latest_word_index]) "
  # puts " (#{word_lengths[latest_word_index]} > #{word_needs[latest_word_index]}) "
  # return :FAILED_NEEDS if (word_lengths[latest_word_index] > word_needs[latest_word_index])

  # puts "  GO_ON? (first word)"
  return :GO_ON if latest_word_index == 0 # e.g. they're on their first word...nothing else to check.

  # puts " (word_lengths[..(latest_word_index-1)].zip(word_needs).any? { |a, b| a != b }) "
  # puts " (word_lengths[..(latest_word_index-1)].zip(word_needs).any? { |a, b| a != b }) "

  # This test *might* be redundant. Try removing it after all else is done.
  puts "  FAILED_NEEDS? (pattern mismatch)"
  return :FAILED_NEEDS if
       word_lengths[..(latest_word_index-1)].zip(word_needs).any? { |a, b|
        puts "  #{a} != #{b}"
        a != b
      }

  # puts '  GO ON...nothing else matched'
  return :GO_ON
end

# Returns an array of possible next steps.
# Steps are each an array: [longer_str, word_needs].
#   longer_str is a new array, exactly one char longer than dst.
#   word_needs is a new array, copied from word_needs and adjusted as needed. (e.g. first-- or first.delete)
# Pays no regard to pattern at all.
# New strings may be too long, too short, or invalid against pattern.
# If dst ends in "#"", and need_counds starts with zero,
#   then a new word is started ("." addedd), and the zero in need_counds is removed.
def find_next_strings(current_string, word_needs)
  puts "find_next_strings('#{current_string}', #{word_needs})"
  possibilities = []
  last_char = current_string[-1]
  current_need = word_needs[0]

  # puts " // last_char=#{last_char}(#{last_char.class}) current_need=#{current_need} "
  # puts " // last_char.nil?=#{last_char.nil?}"
  # binding.pry

  if (last_char == '#' &&  current_need.zero?)
    # puts "  ++ End of a word. Insert separator, leave 0 in front of word_needs"
    possibilities << [ current_string + '.', word_needs.dup]

  elsif (last_char == '#' && current_need.positive?)
    # puts "  ++ Continue word. Add word char, decrement current word_needs"
    new_needs = word_needs.dup
    new_needs[0] -= 1
    possibilities << [ current_string + '#', new_needs]

  # elsif (last_char == '#' && current_need.empty?)
    puts "  ++ Successful solution (trailing #): '#{current_string}'"


  elsif (last_char == '.' &&  current_need.zero?)
    # puts "  ++ Between words. 1) Add separator, and..."
    possibilities << [ current_string + '.', word_needs.dup]

    new_needs = word_needs.dup[1..]
    if new_needs.any?
      # puts "  ++ Between words. 2) ...and, Start new word"
      new_needs[0] -= 1  # Account for new "#" added.
      possibilities << [ current_string + '#', new_needs]
    end

  elsif (last_char == '.' && current_need.positive?)
    # puts "  // Between words and more words needed. (probably the first word in str) Try both:"
    # puts "  ++ Between words. 1) Add separator, and..."
    possibilities << [ current_string + '.', word_needs.dup]

    # puts "  ++ Between words. 2) ...and, Start new word"
    new_needs = word_needs.dup
    new_needs[0] -= 1  # Account for new "#" added.
    possibilities << [ current_string + '#', new_needs]

  # elsif (last_char == '.' && current_need.empty?)
    puts "  ++ Successful solution (trailing .): '#{current_string}'"


  elsif (last_char.nil?)
    # puts "  ++ Start of string. Try both:"

    # puts "  ++ Start of string. 1) Add separator, and..."
    possibilities << [ current_string + '.', word_needs.dup]

    # puts "  ++ Start of string. 2) ...and, Start new word"
    new_needs = word_needs.dup # Don't remove first word!
    new_needs[0] -= 1  # Account for new "#" added.
    possibilities << [ current_string + '#', new_needs]

  else
    raise "  ?? Huh. Nothing happened???"
  end

  puts "  => Possibilities: #{possibilities}"
  possibilities
end















class Record
  def initialize(pattern, counts)
    # puts "Board.init(\"#{pattern}\", [#{counts}])"

    @pattern = pattern.chars

    # This approach keeps needs as an array of ints.
    # This will be used to recursively create many permutations of those needs.
    @word_needs = counts.split(',').map { |n| n.to_i }

    # puts inspect
  end

  def expect_solution(expected)
    # puts inspect
    # puts "expect_solution(#{expected}): pattern=#{@pattern} word_needs=#{@word_needs} haves=#{haves}"
    got = solutions(@pattern, @word_needs)

    msg = "Got #{got}, expected #{expected} from \n#{inspect}"
    if got == expected
      # puts "PASSED: #{msg}\n\n"
    else
      raise "FAIL: #{msg}"
      # raise "FAIL: #{msg}"
    end
  end

  def inspect
    <<~INSP
     <Record: pattern =#{@pattern}
              word_needs=#{@word_needs}
              haves=#{@haves}>
    INSP
              # => #{haves}
  end
end






class Board
  attr_accessor :records

  def parse
    # puts "\nPARSE =========================== "
    # e.g. ?###???????? 3,2,1
    @records = STDIN.map do |line|
                      line.chomp!
                      next if line.empty?
                      # puts "input: [#{line}]"
                      pattern, counts = line.split(' ')
                      Record.new(pattern, counts)
                    end
  end

  def initialize
    # puts "\nINIT =========================== "
    parse

    pp self
  end

  def solutions_a
    99999
  end
end

# board = Board.new
# ans_a = board.solutions_a
# puts "Answer: #{ans_a}"


# Part A:

# Part B:
