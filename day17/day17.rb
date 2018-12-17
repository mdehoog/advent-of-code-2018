require 'treemap'
require 'segment_tree'

class TreeMap
  def []=(key, value)
    put(key, value)
  end
end

class Day17
  def initialize(input)
    @array = []
    @columns = TreeMap.new

    input1 = File.read(input)
    input1.split("\n").each do |line|
      matcher = /(\w)=([\d]+), (\w)=([\d.]+)/.match(line)
      line = matcher[2].to_i
      range = eval(matcher[4]) # rubocop:disable Security/Eval
      if matcher[1] == 'y'
        # horizontal line
        range.each { |column| fill(column, line) }
      else
        range.each { |row| fill(line, row) }
      end
    end

    @minrow = @array.map { |a| (a || []).index { |b| !b.nil? } }.compact.min
    @maxrow = @array.map { |a| (a || []).rindex { |b| !b.nil? } }.compact.max
  end

  def fill_clay
    count = 0
    loop do
      row, range = find_bounded(500, 0)
      break if row.nil?
      range.each do |col|
        next if get2d(col, row)
        next if row < @minrow
        fill(col, row, '~')
        count += 1
      end
    end
    count
  end

  def fill_sand
    count = 0
    sand = find_sand(500, 0)
    sand.each do |x, y|
      next if get2d(x, y)
      next if y < @minrow
      fill(x, y, '|')
      count += 1
    end
    count
  end

  def fill(x, y, value = '#')
    (@columns[x] ||= TreeMap.new)[y] = [x, y]
    (@array[x] ||= [])[y] = value
  end

  def get2d(x, y)
    return nil if @array[x].nil?
    @array[x][y]
  end

  def to_s
    @array.map { |a| (a || []).map { |e| e || '.' }.join('') }.join("\n")
  end

  def find_bounded(x, y, searched = Set.new)
    return nil if searched.include?([x, y])
    searched << [x, y]

    col, row = search_vertical(x, y)
    return nil if col.nil?

    bounds = [false, false]
    [-1, 1].each_with_index do |direction, index|
      x2 = x
      loop do
        x2 += direction
        if get2d(x2, row - 1)
          # wall
          bounds[index] = x2
          break
        end
        next if get2d(x2, row) # has a floor, go to next
        bounded = find_bounded(x2, row, searched)
        return bounded if bounded
        break
      end
    end

    return [row - 1, bounds[0]..bounds[1]] if bounds.all?

    nil
  end

  def find_sand(x, y, searched = Set.new, result = Set.new)
    return result if searched.include?([x, y])
    searched << [x, y]

    col, row = search_vertical(x, y)
    row = @maxrow if col.nil?

    # vertical
    (y..row).each { |r| result << [x, r] }

    # bedrock
    return result if col.nil?

    [-1, 1].each do |direction|
      currentx = x
      loop do
        currentx += direction
        break if get2d(currentx, row - 1) # stop at wall
        # no floor
        break find_sand(currentx, row - 1, searched, result) unless get2d(currentx, row)
        # has a floor, mark as sand
        result << [currentx, row - 1]
      end
    end

    result
  end

  def search_vertical(x, y)
    rows = @columns[x]
    return nil if rows.nil?
    key = rows.higher_key(y)
    return nil if key.nil?
    rows[key]
  end
end

day17 = Day17.new('input1.txt')
water = day17.fill_clay
sand = day17.fill_sand

puts water + sand
puts water
