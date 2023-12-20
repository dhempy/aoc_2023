

# Returns the number of solutions to the input

def solutions(pattern, word_needs, str = '')
  puts "solutions(#{pattern}, #{word_needs}, #{str})"

  action = check_solution(pattern, word_needs, str)

  case action
  when 'GO_ON'
    puts "   GO_ON: #{str}"
    # return find_next_strings(current_string, word_needs).sum do
    #                                            |longer_str, word_needs|
    #   solutions(pattern, word_needs, longer_str)
    # end
  when 'COMPLETE'
    puts "COMPLETE: #{str}"
    return 1
  else
    puts "    HALT: #{str} (#{action})"
    return 0
  end
end

def check_solution(pattern, word_needs, str)
  char_count = pattern.count('#')
  need_count = word_needs.sum

  return 'TOO_WORDY'    if char_count > need_count
  return 'TOO_LONG'     if str.size > pattern.size
  return 'BAD_PATTERN'  if !pattern_match?(pattern, str)


  need_stat = needs_status(word_needs, str, str.size == pattern.size)
  return 'UNMET_NEEDS'  if need_stat == FAILED_NEEDS
  return 'UNMET_NEEDS'  if need_stat == GO_ON
  return 'GO_ON'        if str.size < pattern.size

  return 'COMPLETE'     if str.size == pattern.size ## This may be too weak.

  return 'UNKNOWN!!!'
  # To do: Find many more ways to strike down INVALID attempts early on.
end

# Only checks through str. string may become invalid when it grows longer.
def pattern_match?(pattern, str)
  str.chars.zip(pattern.chars).all? do |s, p|
    # puts "patern_match(#{p}, #{s})"
    p == s || p=='?'
  end
end

# Only checks through str. string may become invalid when it grows longer.
# if fully, then the needs must be fully, exactly met.
def needs_status(word_needs, str, fully)
  puts "needs_status?(#{word_needs}, '#{str}', #{fully})"
  # binding.pry
  word_lengths = str.split('.').map(&:length).select(&:positive?)
  puts "str word lengths: #{word_lengths}"
  return 'GO_ON' if word_lengths.empty? && !fully

  latest_word = word_lengths.count - 1
  puts "latest_word: #{latest_word}"
  puts " (word_lengths[latest_word] <= word_needs[latest_word]) "
  puts " (#{word_lengths[latest_word]} <= #{word_needs[latest_word]}) "

  return 'COMPLETE' if fully && word_lengths == word_needs
  return 'FAILED_NEEDS' if fully && word_lengths != word_needs

  if (
       (word_lengths[latest_word] <= word_needs[latest_word]) &&
       (word_lengths[..(latest_word-1)].zip(word_needs).all? { |have, need| have == need })
     )
    return 'GO_ON'
  end
end

# Returns an array of possible next steps.
# Pays no regard to pattern at all.
# New strings may be too long, too short, or invalid against pattern.
# If dst ends in "#"", and need_counds starts with zero,
#   then a new word is started ("." addedd), and the zero in need_counds is removed.
# Steps are each an array: [longer_str, word_needs].
#   longer_str is a new array, exactly one char longer than dst.
#   word_needs is a new array, copied from word_needs and adjusted as needed.
# def find_next_strings(current_string, word_needs)
#   possibilities = []
#   last_char = current_string[-1]
#   current_need = word_needs[0]

#   if (last_char == '#' &&  current_need.zero?)
#     puts "  ++ End of a word. Insert separator, remove word from word_needs"
#     possibilities << [ current_string + '.', word_needs.dup[1..]]

#   else if (last_char == '#' and current_need.positive?)
#     puts "  ++ Continue word. Add word char, decrement current word_needs"
#     new_needs = word_needs.dup
#     new_needs[0] -= 1
#     possibilities << [ current_string + '#', new_needs]

#   else if (last_char == '#' and current_need.empty?)
#     puts "  ++ Successful solution!"

#   else if (last_char == '.' &&  current_need.zero?)
#     puts "  // Between words. Try both:"
#     puts "  ++ Between words. 1) Add separator, and..."
#     possibilities << [ current_string + '.', word_needs.dup]

#     puts "  ++ Between words. 2) ...and, Start new word"
#     new_needs = word_needs.dup[1..]
#     new_needs[0] -= 1  # Account for new "#" added.
#     possibilities << [ current_string + '#', new_needs]

#   else if (last_char == '.' and current_need.positive?)
#     raise "  ?? HUH? should't ever see this."

#   else if (last_char == '.' and current_need.empty?)
#     puts "  ++ Successful solution!"

#   else if (last_char.nil?)
#     puts "  ++ Start of string. Try both:"

#     puts "  ++ Start of string. 1) Add separator, and..."
#     possibilities << [ current_string + '.', word_needs.dup]

#     puts "  ++ Start of string. 2) ...and, Start new word"
#     new_needs = word_needs.dup # Don't remove first word!
#     new_needs[0] -= 1  # Account for new "#" added.
#     possibilities << [ current_string + '#', new_needs]
#   end

#   possibilities
# end















# class Record
#   def initialize(pattern, counts)
#     puts "Board.init(\"#{pattern}\", [#{counts}])"

#     @pattern = pattern.chars

#     # This approach keeps needs as an array of ints.
#     # This will be used to recursively create many permutations of those needs.
#     @word_needs = counts.split(',').map { |n| n.to_i }

#     puts inspect
#   end

#   def expect_solution(expected)
#     # puts inspect
#     puts "expect_solution(#{expected}): pattern=#{@pattern} word_needs=#{@word_needs} haves=#{haves}"
#     got = solutions(@pattern, @word_needs)

#     msg = "Got #{got}, expected #{expected} from \n#{inspect}"
#     if got == expected
#       puts "PASSED: #{msg}\n\n"
#     else
#       raise "FAIL: #{msg}"
#       # raise "FAIL: #{msg}"
#     end
#   end

#   def inspect
#     <<~INSP
#      <Record: pattern =#{@pattern}
#               word_needs=#{@word_needs}
#               haves=#{@haves}>
#     INSP
#               # => #{haves}
#   end
# end



# # # Don't need to handle edge cases:
# # Record.new('', '').expect_solution(1)
# # Record.new('', '1').expect_solution(0)
# # Record.new('.', '').expect_solution(1)

# # # Simple, undamaged cases:
# Record.new('#', '1').expect_solution(1)
# # Record.new('.#', '1').expect_solution(1)
# # Record.new('...#...', '1').expect_solution(1)
# # Record.new('#.', '1').expect_solution(1)
# # Record.new('##', '1').expect_solution(0)
# # Record.new('##', '2').expect_solution(1)

# # # With gaps in word_needs:
# Record.new('#.##', '1,2').expect_solution(1)
# # Record.new('#..##', '1,2').expect_solution(1)
# # Record.new('#..##', '1,3').expect_solution(0)
# # Record.new('#..##...#..###...', '1,2,1,3').expect_solution(1)

# # # with damaged records:
# # Record.new('?', '1').expect_solution(1)
# # Record.new('???', '1').expect_solution(3)
# # Record.new('#?', '1').expect_solution(1)
# # Record.new('?#', '1').expect_solution(1)
# # Record.new('?##', '3').expect_solution(1)
# # Record.new('#?', '2').expect_solution(1)
# # Record.new('.##?...', '3').expect_solution(1)

# # Record.new('.???', '2').expect_solution(2)
# # Record.new('.???.', '1').expect_solution(3)
# # Record.new('#??', '1,1').expect_solution(1)
# # Record.new('???', '1,1').expect_solution(1)
# # Record.new('.?.?.', '1,1').expect_solution(1)
# # Record.new('.??.?.', '1,1').expect_solution(2)
# # Record.new('.?.??.', '1,1').expect_solution(2)
# Record.new('???.???', '1,2').expect_solution(6)


# Record.new('???', '1,1').expect_solution(1)
# Record.new('?###????????', '3,2,1').expect_solution(10)




# class Board
#   attr_accessor :records

#   def parse
#     puts "\nPARSE =========================== "
#     # e.g. ?###???????? 3,2,1
#     @records = STDIN.map do |line|
#                       line.chomp!
#                       next if line.empty?
#                       puts "input: [#{line}]"
#                       pattern, counts = line.split(' ')
#                       Record.new(pattern, counts)
#                     end
#   end

#   def initialize
#     puts "\nINIT =========================== "
#     parse

#     pp self
#   end

#   def solutions_a
#     99999
#   end
# end

# board = Board.new
# ans_a = board.solutions_a
# puts "Answer: #{ans_a}"


# # Part A:

# # Part B:
