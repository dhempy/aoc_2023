
def initial_map(ranges)
  # puts ranges
  lane = {
            label: 'START-to-seed',
            from_stuff: 'START',
            to_stuff: 'seed',
            terminal_id: {},
            maps: []
          }

  ranges.each_slice(2) do |start, len |
    stop = start + len - 1
    dest = start # No shift.
    add_map(lane, start, stop, dest)
  end

  @lanes["START-HERE"] = lane
end

def parse
  @seeds = STDIN.readline
                .match(/seeds: (.*)/)
                .captures
                .first
                .split
                .map(&:to_i)
  initial_map(@seeds)

  STDIN.readline
  STDIN.read.split("\n\n").each do |txt|
    # puts "-------------\n#{txt}"
    (label, lines) = txt.match(/(.*) map:\n(.*)/m).captures
    # puts "label: #{label}"
    (from_stuff, to_stuff) = label.split('-to-')
    # puts " lines: #{lines}"

    lane = {
            label: label,
            from_stuff: from_stuff,
            to_stuff: to_stuff,
            terminal_id: {}, # the ID of the thing (e.g. location) in the final state.
            min_mapped: nil,
            max_mapped: nil,
            maps: [],
          }

    lines.split("\n").map do |line|
      # puts "  line: #{line}"
      (dest, start, len) = line.match(/(\d+) (\d+) (\d+)/).captures.map(&:to_i)
      # puts "     d:#{dest} s:#{start} l:#{len}"
      # delta = dest - start
      stop = start + len - 1
      # {
      #   start: start, stop: stop, len: len, dest: dest, delta: delta,
      #   terminal_id: {},
      #   total_delta: nil,
      # }

      add_map(lane, start, stop, dest)
    end

    seed_missing_maps(lane)
    @lanes[from_stuff] = map
  end
end

# def next_steeeeeep(step, id)
#   # puts "  next_steeeeeep(#{step}, #{id})"
#   step[:maps].find do |maybe|
#     # puts "    test #{maybe}"
#     true if id.between?(maybe[:start], maybe[:stop])
#   end #.tap { |x| puts "    Found next_steeeeeep: #{x}"}
# end

def seed_missing_maps(lane)
  a = lane[:maps].map{|m| m[:start]}.min
  b = lane[:maps].map{|m| m[:stop]}.max
  range = (a..b)
  add_missing_maps(lane, range)
end

# create a pass-through, zero-delta map:
def add_map(lane, start, stop, dest=start)
    len = stop - start + 1
    delta = dest - start

    new_map =
      {
        start: start, stop: stop, len: len, dest: dest, delta: delta,
        terminal_id: {},
        total_delta: nil,
      }

    puts "     Addding map: #{new_map}"
    lane[:maps] << new_map
end

def add_missing_maps(lane, range)
  puts "add_missing_maps(lane, #{range})"
  pp lane
  # return if range.nil? || range.empty?
  return if lane[:min_mapped] && range.min >= lane[:min_mapped] && range.max <= lane[:max_mapped]
  return if lane[:from_stuff] == 'START' # Never expand starting maps!

  lane[:min_mapped] = lane[:maps].map{|m| m[:start]}.min
  lane[:max_mapped] = lane[:maps].map{|m| m[:stop]}.max

  if range.min < lane[:min_mapped]
    add_map(lane, range.min, lane[:min_mapped]-1)
  end

  if range.max > lane[:max_mapped]
    add_map(lane, lane[:max_mapped] + 1, range.max)
  end

  prev = nil

  puts "lane:"
  pp lane

  puts "maps:"
  pp lane[:maps]

  lane[:maps].sort_by{ |m|
    # puts "a: #{a}"
    # puts "b: #{b}"
    m[:start] }.each do |one|
    if prev
      if prev[:stop]+1 < one[:start]
        add_map(lane, prev[:stop] + 1, one[:start] - 1)
      end
    end
    prev = one
  end

  lane[:min_mapped] = lane[:maps].map{|m| m[:start]}.min
  lane[:max_mapped] = lane[:maps].map{|m| m[:stop]}.max
end

# returns the lowest terminal_id from this point within range.
def navigate(from_stuff, final_stuff, range = nil)
  puts "\n navigate(#{from_stuff}, #{final_stuff}, #{range})..."
  raise "LOCATION NOT FOUND" unless from_stuff

  if from_stuff == final_stuff
    # lane[:terminal_id] = range
    puts "  FOUND LOCATION! best is #{range.min}"
    return range.min
  end

  lane = @lanes[from_stuff]
  puts "  lane: ++++++++++++++++++++++++"
  pp lane

  puts "   ALREADY SOLVED: #{lane[:terminal_id][range]}" if lane[:terminal_id][range]
  return lane[:terminal_id][range] if lane[:terminal_id][range]

  # puts "...WORKING HARD..."
  # sleep 1

  range ||= (lane[:min_mapped]..lane[:max_mapped])
  puts range.inspect
  add_missing_maps(lane, range) if range

  candidates = lane[:maps].map do |step|
    puts "   lane #{lane[:label]} step before: #{step}"
    delta = (step && step[:delta]) || 0

    # find best path within this map, over the requested range
    range_start = max(step[:start], range.min)
    range_stop  = min(step[:stop], range.max)
    sub_range = (range_start..range_stop)
    terminal_id = navigate(lane[:to_stuff], final_stuff, sub_range)
    lane[:terminal_id][range] ||= terminal_id

    puts "   lane #{lane[:label]} step after: #{step}"
    terminal_id
  end

  puts " +++++++ Sort candidates #{candidates} to find best final..."
  pp lane
  # pp lane[:maps]
  # puts "   #{lane[:maps].pluck(:terminal_id)}"
  best_terminal_id = candidates.min
  lane[:terminal_id][range] = best_terminal_id
  puts "terminal_id should be set: ~~~~~~~~~~~~~~~~~~"
  # pp lane
  best_terminal_id

  # maybe I should return best_step instead of best_terminal_id? or best_map?
  # maybe need to rename @lanes to @lanes?
end


def process
  @best = navigate('START-HERE', 'location')
  puts "****** WINNER: #{@best}"
end

# brute force too slow:
# def process
#   @seed_ranges.each do |range|
#     puts "\n============ TEST FROM #{range}"
#     range.each do |seed|
#       # puts "  ========== test #{seed}"

#       @seed_locations[seed] = navigate('seed', 'location', seed)
#     end
#   end
# end

# def terminal_id
#   @seed_locations.sort_by{|key,val| val}.first
# end

@seeds = {}
@lanes = {}
@seed_locations = {}

puts "parse..."
parse
puts "\nseeds: ==========================================="
pp @seeds

puts "\nmaps: ==========================================="
pp @lanes

# puts "\nseed_ranges: ==========================================="
# pp @seed_ranges.inspect


puts "\nprocess: ==========================================="
process

puts "\nmaps: (FINAL) ==========================================="
pp @lanes

# exit


# puts "\nseed_locations: ==========================================="
# pp @seed_locations
puts "\nbest: ==========================================="
pp @best

ans = @best



puts "\nAnswer: #{ans} ==========================================="
puts " #{ans} should equal location 62"

puts "\n test answer =========="

confirmation  = navigate('seed', 'location', 78)
puts " #{confirmation} should equal location 62"

confirmation  = navigate('seed', 'location', 56)
puts " #{confirmation} should equal location 62"

confirmation  = navigate('seed', 'location', 93)
puts " #{confirmation} should equal location 62"




# Seed 79,
# soil 81,
# fertilizer 81,
# water 81,
# light 74,
# temperature 78,
# humidity 78,
# location 82.

