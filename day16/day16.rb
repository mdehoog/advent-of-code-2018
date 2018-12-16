require 'set'
require 'graph_matching'

COMMANDS = {
  addr: ->(registers, a, b, c) { registers[c] = registers[a] + registers[b] },
  addi: ->(registers, a, b, c) { registers[c] = registers[a] + b },
  mulr: ->(registers, a, b, c) { registers[c] = registers[a] * registers[b] },
  muli: ->(registers, a, b, c) { registers[c] = registers[a] * b },
  banr: ->(registers, a, b, c) { registers[c] = registers[a] & registers[b] },
  bani: ->(registers, a, b, c) { registers[c] = registers[a] & b },
  borr: ->(registers, a, b, c) { registers[c] = registers[a] | registers[b] },
  bori: ->(registers, a, b, c) { registers[c] = registers[a] | b },
  setr: ->(registers, a, _, c) { registers[c] = registers[a] },
  seti: ->(registers, a, _, c) { registers[c] = a },
  gtir: ->(registers, a, b, c) { registers[c] = a > registers[b] ? 1 : 0 },
  gtri: ->(registers, a, b, c) { registers[c] = registers[a] > b ? 1 : 0 },
  gtrr: ->(registers, a, b, c) { registers[c] = registers[a] > registers[b] ? 1 : 0 },
  eqir: ->(registers, a, b, c) { registers[c] = a == registers[b] ? 1 : 0 },
  eqri: ->(registers, a, b, c) { registers[c] = registers[a] == b ? 1 : 0 },
  eqrr: ->(registers, a, b, c) { registers[c] = registers[a] == registers[b] ? 1 : 0 },
}.freeze

potential_mapping = COMMANDS.keys.map { |k| [k, Set.new] }.to_h

# part 1

part1 = File.read('day16part1.txt').split("\n\n").map do |p1|
  %i[before command after].zip(p1.split("\n").map do |line|
    line.split(' ').map(&:to_i)
  end).to_h
end

total = part1.count do |p1|
  matching = COMMANDS.count do |k, v|
    registers = p1[:before].clone
    v.call(registers, *p1[:command][1..-1])
    potential_mapping[k] << p1[:command][0] if registers == p1[:after]
    registers == p1[:after]
  end
  matching >= 3
end

puts "Total with more than 3: #{total}"

# part 2

graph_indices = potential_mapping.map.with_index do |(_, v), i|
  v.map { |j| [i + 1, j + 17] }
end.flatten

bipartite_graph = GraphMatching::Graph::Bigraph[*graph_indices]
matching = bipartite_graph.maximum_cardinality_matching
mapping = matching.edges.map { |i, j| [i - 17, COMMANDS.keys[j - 1]] }.to_h

puts "Command mapping: #{mapping.inspect}"

input2 = File.read('day16part2.txt')
part2 = input2.split("\n").map { |s| s.split(' ').map(&:to_i) }

registers = [0, 0, 0]
part2.each do |command|
  COMMANDS[mapping[command[0]]].call(registers, *command[1..-1])
end

puts "Final registers: #{registers.inspect}"
