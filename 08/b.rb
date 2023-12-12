class Node
  attr_accessor :raw, :name, :steps

  def initialize(line)
    self.raw = line

    # AAA = (BBB, CCC)
    # puts "  line: [#{line}]"
    (name, left, right) = line.match(/(\w+) = \((\w+), (\w+)\)/).captures
    self.name = name

    self.steps = {}
    self.steps['L'] = left  # BBB
    self.steps['R'] = right # CCC
  end

  def advance(turn)
    hence = steps[turn]
    puts "  #{self.name}.advance(#{turn}) => hence: #{hence}"
    hence

    # steps[turn]
  end

  def finished?
    name[-1] == 'Z'
  end

  def shortest_path(board, dest, so_far = 0)
    puts "  #{self.name}.shortest_path(board, #{dest}, #{so_far})"
    if (dest == self.name)
      puts "  FOUND #{dest} in #{so_far} steps!"
      return so_far
    end
    turn = board.turns[so_far % board.turns_len]
    hence = steps[turn]

    puts "  turn: #{turn}, hence: #{hence}"
    board.nodes[hence].shortest_path(board, dest, 1+so_far)

    # steps.values.min do |toward|
    #   Board.nodes[toward].shortest_path(dest, 1+so_far)
    # end
  end
end


class Board
  attr_accessor :nodes, :turns, :turns_len, :ghosts

  def parse
    puts "\nPARSE =========================== "

    # e.g. LLRRRLLLRLRLRL
    step_string = STDIN.readline.match(/([LR]+)/).captures.first
    self.turns = step_string.chars
    self.turns_len = turns.size
    puts "turns: #{turns} (num: #{turns_len})"

    self.nodes = {}
    STDIN.each do |line|
      line.chomp!
      next if line.empty?
      puts "input: [#{line}]"
      node = Node.new(line.chomp)
      self.nodes[node.name] = node
    end
  end

  def initialize
    puts "\nINIT =========================== "
    parse

    self.ghosts = nodes.keys.select { |n| n[-1] == 'A' }

    puts "turns:"
    pp turns
    puts "nodes:"
    pp nodes
    puts "ghosts:"
    pp ghosts
  end

  def advance_fleet(turn)
    puts
    ghosts.each_with_index { |g, n| ghosts[n] = nodes[g].advance(turn) }
  end

  def fleet_finished?
    ghosts.all? { |g| g[-1] == 'Z' }
  end

  def ghost_fleet_navigate
    puts "\nghost_fleet_navigate() =========================== "

    steps = 0
    until fleet_finished?
      puts "steps: #{steps}"  if steps%1000000 == 0
      # pp ghosts
      turn = turns[steps % turns_len]
      advance_fleet(turn)
      steps += 1

      # raise if steps > 10
    end

    puts "FLEET FINISHED in #{steps} steps!"
    steps
  end

  def solve
    ghost_fleet_navigate
  end
end

# Next strategy:
# Next strategy:
# Next strategy:
# Next strategy:
# Next strategy:
# Next strategy:
# # Next strategy:
#   - Measure the repeat period of each ghost
#   - Find the least common multiple of those periods. Hopefully that's the solution.
#   - If not, add in the pre-repeat offset of each, and ???


board = Board.new

ans = board.solve

puts "Answer: #{ans}"


# Part A:
# Answer: 13019 - That's the right answer!



# Failing when Iterating for 12 hours:
# steps: 20,879,900,000
# steps: 20,880,000,000
# ^Cb.rb:23:in `advance': Interrupt