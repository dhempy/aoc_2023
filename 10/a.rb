require 'pry'
require "readline"
Readline.input = IO.new(IO.sysopen("/dev/tty", "r+"))

S = [+1, 0]  # South (visually) is a HIGHER numbered row, based on input.
N = [-1, 0]  # North (visually) is a LOWER  numbered row, based on input.
E = [0, +1]
W = [0, -1]

PASSAGE = {
  '|' => { S => S, N => N },
  '-' => { E => E, W => W },
  'F' => { N => E, W => S },
  '7' => { N => W, E => S },
  'J' => { S => W, E => N },
  'L' => { S => E, W => N },
}

WALL = '#'

class Node
  attr_accessor :c, :dist

  def initialize(c)
    @c = c
  end

  def next_move(dir)
    # puts "  #{c}.next_move(#{dir}):"
    # pp PASSAGE
    PASSAGE.dig(c, dir)
      .tap {|x| @c = WALL}
  end

  def to_s
    case c
    when 'S'; 'S'
    when '|'; '│' # connected
    when '-'; '─' # connected
    # when '|'; '|' # spaced
    # when '-'; '-' # spaced
    when 'F'; '┌'
    when '7'; '┐'
    when 'J'; '┘'
    when 'L'; '└'
    when '*'; '*'
    when '.'; '.'
    else;     c
    end
  end

  def inspect
    to_s
  end
end

class Board
  attr_accessor :grid, :curr_row, :curr_col, :start_row, :start_col, :dist

  def initialize
    @grid = []
  end

  def parse
    puts "\n PARSE =========================== "

    #    .....
    #    .S-7.
    #    .|.|.
    #    .L-J.
    #    .....

    self.grid = STDIN.map.with_index do |line, row|
                    line.chomp!
                    next if line.empty?
                    # puts "input: [#{line}]"
                    line.chars.map.with_index do |ch, col|
                      # puts "  char: #{ch}"
                      @start_row, @start_col = row, col if ch == 'S'
                      # node = Node.new(ch)
                      Node.new(ch)
                    end
                  end
  end


  def finished?
    # puts " grid[#{@curr_row}][#{@curr_col}].c == 'S' => #{grid[@curr_row][@curr_col].c == 'S'}  (dist = #{@dist}) "
    puts @dist if @dist % 100 == 0
    @here.c == 'S'
  end

  def go(dir)
    # puts "    Go(#{dir})"
    # puts "      from #{@curr_row},#{@curr_col} => #{@here}"
    @curr_row += dir[0]
    @curr_col += dir[1]
    @here = grid[@curr_row][@curr_col]
    @dist = @dist + 1
    # puts "        to #{@curr_row},#{@curr_col} => #{@here}"
  end

  # records the full distance of the loop in @dist,
  # and marks loop with WALL characters.
  def survey_pipe
    puts "\n SURVEY LOOP =========================== "

    @curr_row, @curr_col = @start_row, @start_col
    @here = grid[@curr_row][@curr_col]
    @dist = 0
    delta = S # This is a valid starting direction for the given input. Adjust as needed.

    loop do
      # print "\033[0;0H";  puts inspect
      go(delta)
      delta = @here.next_move(delta)
      # puts "  next_move returned #{delta}"
      break if finished? || delta.nil?
    end

    inspect
  end

  def solve_a
    puts "\n SOLVE A =========================== "

    inspect
    survey_pipe
    @part_a_solution = @dist / 2
  end

  # returns a new scaled-up board, with twice the resolution in both dimensions
  def explode
    big_board = Board.new

    @grid.each_with_index do |line, r|
      br = r * 2
      r1 = big_board.grid[br  ] = []
      r2 = big_board.grid[br+1] = []

      line.each_with_index do |ch, c|
        c1 = c * 2
        c2 = c1 + 1
        # puts "ch.c: #{ch.c}"
        case ch.c
        when '-' # '─'
          r1[c1] = Node.new(ch ); r1[c2] = Node.new('-');
          r2[c1] = Node.new(' '); r2[c2] = Node.new(' ');
        when '|' # '│'
          r1[c1] = Node.new(ch ); r1[c2] = Node.new(' ');
          r2[c1] = Node.new('|'); r2[c2] = Node.new(' ');
        when 'F' # '┌'
          r1[c1] = Node.new(ch ); r1[c2] = Node.new('-');
          r2[c1] = Node.new('|'); r2[c2] = Node.new(' ');
        when '7'
          r1[c1] = Node.new(ch ); r1[c2] = Node.new(' ');
          r2[c1] = Node.new('|'); r2[c2] = Node.new(' ');
        when 'J'
          r1[c1] = Node.new(ch ); r1[c2] = Node.new(' ');
          r2[c1] = Node.new(' '); r2[c2] = Node.new(' ');
        when 'L' # '└'
          r1[c1] = Node.new(ch ); r1[c2] = Node.new('-');
          r2[c1] = Node.new(' '); r2[c2] = Node.new(' ');
        when 'J'
          r1[c1] = Node.new(ch ); r1[c2] = Node.new(' ');
          r2[c1] = Node.new(' '); r2[c2] = Node.new(' ');
        when '.'
          r1[c1] = Node.new(ch ); r1[c2] = Node.new('.');
          r2[c1] = Node.new('.'); r2[c2] = Node.new('.');
        when 'S'
          r1[c1] = Node.new(ch ); r1[c2] = Node.new('-');
          r2[c1] = Node.new('|'); r2[c2] = Node.new(' ');
          big_board.start_row, big_board.start_col = row, col if ch == 'S'
        else
          raise "Huh? ch is #{ch}"
        end
      end

      puts "r1: #{r1}"
      puts "r2: #{r2}"
    end

    big_board
  end

  def solve_b
    puts "\n SOLVE B =========================== "
    inspect

    # @curr_row, @curr_col = @start_row, @start_col
    # @here = grid[@curr_row][@curr_col]
    # @dist = 0
    # delta = S # This is a valid starting direction for the given input. Adjust as needed.

    # loop do
    #   print "\033[0;0H"
    #   puts inspect
    #   go(delta)
    #   delta = @here.next_move(delta)
    #   # puts "  next_move returned #{delta}"
    #   break if finished? || delta.nil?
    # end
    # inspect

    @part_b_solution = -123
  end

  def inspect
    "Cursor: (#{@curr_row},#{@curr_col})}\n" +
      grid.map(&:join).join("\n")
  end
end


board_a = Board.new

board_a.parse
pp board_a
puts "Board_a size: #{board_a.grid.length}"


ans_a = board_a.solve_a
pp board_a
puts "Part A Answer: #{ans_a}"


board_b = board_a.explode
pp board_b
puts "Board_b size: #{board_b.grid.length}"

binding.pry
binding.pry

ans_b = board_a.solve_b
puts "Part B Answer: #{ans_b}"


# expected = "DUNNO"
# raise "WRONG! #{ans} should be #{expected}" unless ans == expected


# Part A: Answer: 6599 -  That's the right answer!