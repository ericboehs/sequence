input = ARGV.join.tr(',', ' ').gsub(/\[/, ', %w[')
input[0] = '['
BOARD = eval input + ']'
# rescue
#   [%w[W R R R R R R R R W],
#    %w[R R R R R O O O R R],
#    %w[O B B O O O O R O R],
#    %w[O O B O O O R O O R],
#    %w[O O O O O R O O O R],
#    %w[G G G G G G G G O O],
#    %w[O G O O O O O O O O],
#    %w[O G O O O O O O O O],
#    %w[O O O O O O O O O O],
#    %w[W O O O O O O O O W]]

def diagonalize board
  arr = board
  padding = arr.size - 1
  padded_matrix = []

  arr.each do |row|
    inverse_padding = arr.size - padding
    padded_matrix << ([nil] * inverse_padding) + row + ([nil] * padding)
    padding -= 1
  end

  padded_matrix.transpose.map(&:compact)
end

def find_consecutives
  lines = Hash.new 0
  [BOARD, BOARD.transpose.map(&:reverse), diagonalize(BOARD), diagonalize(BOARD.transpose.map(&:reverse))].each do |board|
    %w[B G R].each do |color|
      board.each do |row|
        line = row.join

        if line.include?("W" + color * 8) || line.include?(color * 8 + "W") || line.include?(color * 9)
          lines[color] += 2
          next
        end

        if line.include?(color * 5) || line.include?("W" + color * 4) || line.include?(color * 4 + "W")
          lines[color] += 1
        end
      end
    end
  end
  lines
end

puts find_consecutives
