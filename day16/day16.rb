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

input1 = File.read('day16part1.txt')
part1 = input1.split("\n\n")

part1 = part1.map do |p1|
  lines = p1.split("\n")
  {
    before: lines[0].split(' ').map(&:to_i),
    command: lines[1].split(' ').map(&:to_i),
    after: lines[2].split(' ').map(&:to_i)
  }
end

mapping = COMMANDS.keys.map { |k| [k, Set.new] }.to_h

total = part1.count do |p1|
  before = p1[:before]
  command = p1[:command]
  after = p1[:after]
  matching = COMMANDS.count do |k, v|
    registers = before.clone
    v.call(registers, command[1], command[2], command[3])
    mapping[k] << command[0] if registers == after
    registers == after
  end
  matching >= 3
end
puts "Total with more than 3: #{total}"

graph = mapping.map.with_index do |(_, v), i|
  v.map { |j| [i + 1, j + 17] }
end.flatten

g = GraphMatching::Graph::Bigraph[*graph]
m = g.maximum_cardinality_matching
mapping = m.edges

commands = mapping.map do |i, j|
  i -= 16
  [i - 1, COMMANDS.keys[j - 1]]
end.to_h

puts "Command mapping: #{commands.inspect}"

input2 = File.read('day16part2.txt')
part2 = input2.split("\n").map { |s| s.split(' ').map(&:to_i) }

registers = [0, 0, 0]
part2.each do |command|
  COMMANDS[commands[command[0]]].call(registers, command[1], command[2], command[3])
end

puts "Final registers: #{registers.inspect}"
