
class Buffer
  attr_accessor :vals, :cursor, :len

  def initialize(vals = [])
    @vals = vals
    @cursor = 0
    @len = vals.size
  end

  def get
    @vals[@cursor]
      .tap { advance }
  end

  def peek
    @vals[@cursor]
  end

  def advance
    @cursor +=1
  end

  def revert
    @cursor -=1
  end

  def empty?
    vals.empty? || cursor == len
  end

  def to_s
    if 0 == cursor
      "[^#{vals[cursor..]&.join}] (#{cursor}/#{len})"
    else
      "[#{vals[..(cursor-1)]&.join} ^#{vals[(cursor)..]&.join}] (#{cursor}/#{len})"
    end
  end
end

class Record
  attr_accessor :srcs, :needs, :haves

  def initialize(pattern, counts)
    puts "init(\"#{pattern}\", [#{counts}])"

    @srcs  = Buffer.new(pattern.chars)
    puts "srcs : #{@srcs}"

    raw_needs = counts.split(',').map { |n| '#' * n.to_i }.join('~')
    # puts "9. raw_needs: #{raw_needs}"
    @needs = Buffer.new(raw_needs.chars)
    puts "needs: #{@needs}"

    @haves = Buffer.new
    puts "haves: #{@haves}"
    # puts inspect
    # puts "slots[0]: #{@slots[0].class}"
    # puts "needs.class: #{@needs.class}"
    # puts "needs[0]: #{@needs[0]}"
    # puts "needs[0].class: #{@needs[0].class}"
  end

  # Equipped with this information, it is your job to figure out how
  # many different arrangements of operational and broken springs fit
  # the given criteria in each row.

    # ?###???????? 3,2,1

    # .###.##.#...
    # .###.##..#..
    # .###.##...#.
    # .###.##....#
    # .###..##.#..
    # .###..##..#.
    # .###..##...#
    # .###...##.#.
    # .###...##..#
    # .###....##.#

    # ?### 3   => 1
    # .###

    # ?### 2   => 0
    # .###

    # .### 3 => 1

  def solutions(srcs, needs, haves, depth=0)
    puts "  solutions():"
    puts inspect


    # puts "    ?success?"
    return 1 if srcs.empty? && needs.empty?
    # puts "    ?too much need?"
    # return 0 if srcs.empty?
    # puts "    ?too much src?"
    # return 0 if needs.empty?
    raise "TOO DEEP!" if depth > 50   # REMOVE WHEN FOR REALS!!!!!!!

    got = srcs.get
    # puts "    Got : #{got}"
    need = needs.peek
    # puts "    Need: #{need}"

    count = 0

    case got
    when '#'
      case need
      when '~'
        puts "      yep: neeeded [~] got [#]. Advance need once for ~, and once for # and continue."
        puts "           needs before    get: #{needs}"
        needs.advance # consume ~
        next_need = needs.get # get the next need (should be) #.
        puts "           next_need: #{next_need}"
        puts "           needs after     get: #{needs}"
        if next_need == '#'
          count = solutions(srcs, needs, haves, depth+1)
          puts "           found #{count} solutions"
        else
          puts "      nope: source had an unneeded #."
          count = 0
        end
        puts "           needs before revert: #{needs}"
        needs.revert
        needs.revert
        puts "           needs after  revert: #{needs}"
      when '#'
        puts "      yepp: neeeded [#] got [#]. Dig deeper..."
        needs.advance
        count = solutions(srcs, needs, haves, depth+1)
        needs.revert
      when nil
        puts "      nope: neeeded [nothing] got [#]."
        count = 0
      else
        puts "      I'm not sure what to do with need=#{need.inspect}"
        count = 1000
      end

    when '.'
      case need
      when '#'
        puts "      yepp: neeeded [#] got [.]. Advance src, leave need alone and keep looking."
        count = solutions(srcs, needs, haves, depth+1)
      when '~'
        puts "      yepp: neeeded [.] got [.]. Dig deeper..."
        count = solutions(srcs, needs, haves, depth+1)
      when nil
        puts "      yepp: neeeded [nothing] got [.]. Dig deeper..."
        count = solutions(srcs, needs, haves, depth+1)
      else
        puts "      I'm not sure what to do with need=#{need.inspect}"
        count = 1000
      end


    when '?'
      case need
      when '#'
        puts "      yepp: neeeded [#] got [?]. Dig deeper on one path..."
        needs.get
        count = solutions(srcs, needs, haves, depth+1)
        needs.revert
      when '~'
        puts "      yepp: neeeded [~] got [?]. Dig deeper on two paths..."
        puts "        Dig the [.] path..."
        count = solutions(srcs, needs, haves, depth+1)

        puts "        Dig the [#] path..."

        needs.get # Consume the ~ in needs.
        count += solutions(srcs, needs, haves, depth+1)
        needs.revert  # restore the ~ in needs.
      else
        puts "      I'm not sure what to do with need=#{need.inspect}"
        count = 1000
      end


    when nil
      puts "      Nope. Ran out of input without satisfying needs."
      count = 0

    else
      puts "      HUH? I'm not sure what to do with got=#{got.inspect}"
      count = -1000
    end

    srcs.revert
    return count
  end

  # def meet_a_needs
  #   n[-1] -= 1
  #   n.pop if n[-1] == 0
  # end

  # def restore_a_needs
  #   n[-1] -= 1
  #   n.pop if n[-1] == 0
  # end

  def expect_solution(expected)
    # puts inspect
    got = solutions(srcs, needs, haves)

    msg = "Got #{got}, expected #{expected} from \n#{inspect}"
    if got == expected
      puts "PASSED: #{msg}\n\n"
    else
      raise "FAIL: #{msg}"
      # raise "FAIL: #{msg}"
    end
  end

  def inspect
    <<~INSP
     <Record: srcs=\"#{@srcs}\"
              needs=#{@needs}>
    INSP
              # => #{haves}
  end
end



# # Don't need to handle edge cases:
# Record.new('', '').expect_solution(1)
# Record.new('', '1').expect_solution(0)
# Record.new('.', '').expect_solution(1)

# # Simple, undamaged cases:
Record.new('#', '1').expect_solution(1)
# Record.new('.#', '1').expect_solution(1)
# Record.new('...#...', '1').expect_solution(1)
# Record.new('#.', '1').expect_solution(1)
# Record.new('##', '1').expect_solution(0)
# Record.new('##', '2').expect_solution(1)

# # With gaps in needs:
# Record.new('#.##', '1,2').expect_solution(1)
# Record.new('#..##', '1,2').expect_solution(1)
# Record.new('#..##', '1,3').expect_solution(0)
# Record.new('#..##...#..###...', '1,2,1,3').expect_solution(1)

# with damated records:
Record.new('?', '1').expect_solution(1)
Record.new('#?', '1').expect_solution(1)
Record.new('?#', '1').expect_solution(1)
Record.new('#?', '2').expect_solution(1)

# Record.new('#.##', '1,2').expect_solution(1)

# Record.new('.###', '2').expect_solution(0)
# Record.new('?', '1').expect_solution(1)
# Record.new('.##?', '3').expect_solution(1)
# Record.new('.???', '2').expect_solution(2)
# Record.new('#.##', '1,2').expect_solution(1)





class Board
  attr_accessor :records

  def parse
    puts "\nPARSE =========================== "
    # e.g. ?###???????? 3,2,1
    @records = STDIN.map do |line|
                      line.chomp!
                      next if line.empty?
                      puts "input: [#{line}]"
                      pattern, counts = line.split(' ')
                      Record.new(pattern, counts)
                    end
  end

  def initialize
    puts "\nINIT =========================== "
    parse

    pp self
  end

  def solutions_a
    99999
  end
end

board = Board.new
ans_a = board.solutions_a
puts "Answer: #{ans_a}"


# Part A:

# Part B:
