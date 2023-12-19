class Record
  attr_accessor :pattern, :counts, :slots, :needs

  def initialize(pattern, counts)
    puts "init(\"#{pattern}\", [#{counts}])"
    self.pattern = pattern # e.g. "?###????????"
    self.counts = counts   # e.g. "3,2,1"

    self.slots = pattern.chars # e.g. "?#..#" =? ['?', '#', '.', '.', '#']
    self.needs = counts.split(',').map(&:to_i).reverse   # e.g. "3,2,1" => [1, 2, 3] -- Note reverse order for popping.

    # puts inspect
    # puts "slots[0]: #{@slots[0].class}"
    # puts "slots: #{@slots}"
    # puts "needs: #{@needs}"
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


  def solve(s = slots, n = needs, depth = 0)
    puts "  solve(#{s}, #{n}):"
    return 1 if s.empty? && n.empty?
    return 0 if s.empty?
    return 0 if n.empty?
    raise "TOO DEEP!" if depth > 10   # REMOVE WHEN FOR REALS!!!!!!!

    val  = slots[-1]
    rest = slots[0..-2] # if this proves too expensive, don't duplicate, use one array, and change/restore via depth
    # puts "    popped #{val}"

    case val
    when '.'
      solve(rest, n, depth+1)
    when '#'
      sub_needs =
      meet_a_need
      def meet_a_need
        n[-1] -= 1
        n.pop if n[-1] == 0
      end

      def restore_a_need
        n[-1] -= 1
        n.pop if n[-1] == 0
      end

      solve(rest, n, depth+1)

    when '?'
      # try with #:
      solve(rest, n, depth+1)

      # try with .:
      raise "I;m not ready for thsi"
    else

    end
  end

  def expect_solution(expected)
    # puts inspect
    got = solve
    msg = "Got #{got}, expected #{expected} from #{inspect}"
    if got == expected
      puts "PASSED: #{msg}"
    else
      raise "FAIL: #{msg}"
      # raise "FAIL: #{msg}"
    end
  end

  def inspect
    "<Record: pattern=\"#{pattern}\" counts=#{counts}> -- #{slots}::#{needs}"
  end
end


Record.new('', '').expect_solution(1)
Record.new('', '1').expect_solution(0)
Record.new('#', '1').expect_solution(1)
Record.new('?', '1').expect_solution(1)
Record.new('#?', '1').expect_solution(1)
Record.new('#?', '2').expect_solution(1)

# Record.new('.', '').expect_solution(1)
# Record.new('.#', '1').expect_solution(1)
# Record.new('#.', '1').expect_solution(1)
# Record.new('##', '1').expect_solution(0)
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
    self.records = STDIN.map do |line|
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

  def solve_a
    99999
  end
end

board = Board.new
ans_a = board.solve_a
puts "Answer: #{ans_a}"


# Part A:

# Part B:
