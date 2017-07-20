# input = ARGV.join.tr(',', ' ').gsub(/\[/, ', %w[')
# input[0] = '['
# board = eval input + ']'
board = [%w[W O O O O O O O O W],
         %w[O O O O O O O O O O],
         %w[B O O O O O O O O O],
         %w[B O O O O O O O O O],
         %w[B O O O O O O O O O],
         %w[B O O O O O O O O O],
         %w[B O O O O O O O O O],
         %w[B O O O O O O O O O],
         %w[B O O O O O O O O O],
         %w[W O O O O O O O O W]]

class Solver
  def self.diagonalize board
    padding = board.size - 1
    padded_matrix = []

    board.each do |row|
      inverse_padding = board.size - padding
      padded_matrix << ([nil] * inverse_padding) + row + ([nil] * padding)
      padding -= 1
    end

    padded_matrix.transpose.map(&:compact)
  end

  def self.rotate board
    board.transpose.map &:reverse
  end

  attr_accessor :board, :boards, :line_forming_moves

  def initialize board
    self.board = board
    self.boards = {
      horizontal: board,
      vertical: self.class.rotate(board),
      diagonal: self.class.diagonalize(board),
      reverse_diagonal: self.class.diagonalize(self.class.rotate(board))
    }

    self.line_forming_moves = {
      'B' => [],
      'G' => []
    }
    find_consecutives
  end

  def find_consecutives
    lines = Hash.new 0
    boards.each do |direction, board|
      %w[B G R].each do |color|
        board.each_with_index do |row, i|
          line = row.join

          send("detect_#{direction}_winning_move", line, color, i)

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

  def detect_horizontal_winning_move line, color, i
    pattern = "W" + color * 3 + "O"
    self.line_forming_moves[color] << [i, line.index(pattern) + 4] if line.include? pattern

    pattern = "W" + color * 2 + "O" + color
    self.line_forming_moves[color] << [i, line.index(pattern) + 3] if line.include? pattern

    pattern = "W" + color + "O" + color * 2
    self.line_forming_moves[color] << [i, line.index(pattern) + 2] if line.include? pattern

    pattern = "W" + "O" + color * 3
    self.line_forming_moves[color] << [i, line.index(pattern) + 1] if line.include? pattern

    pattern = color + "O" + color * 2 + "W"
    self.line_forming_moves[color] << [i, line.index(pattern) + 1] if line.include? pattern

    pattern = color * 2 + "O" + color + "W"
    self.line_forming_moves[color] << [i, line.index(pattern) + 2] if line.include? pattern

    pattern = color * 3 + "O" + "W"
    self.line_forming_moves[color] << [i, line.index(pattern) + 3] if line.include? pattern

    pattern = color * 4 + "O"
    self.line_forming_moves[color] << [i, line.index(pattern) + 4] if line.include? pattern
    self.line_forming_moves[color] << [i, line.index(pattern) - 1] if line.include?(pattern) && line.index(pattern) - 1 > 0

    pattern = color * 3 + "O" + color
    self.line_forming_moves[color] << [i, line.index(pattern) + 3] if line.include? pattern

    pattern = color * 2 + "O" + color * 2
    self.line_forming_moves[color] << [i, line.index(pattern) + 2] if line.include? pattern

    pattern = color + "O" + color * 3
    self.line_forming_moves[color] << [i, line.index(pattern) + 1] if line.include? pattern
  end

  def detect_vertical_winning_move line, color, i
    pattern = "W" + color * 3 + "O"
    self.line_forming_moves[color] << [line.index(pattern) + 9 - 4, i] if line.include? pattern

    pattern = "W" + color * 2 + "O" + color
    self.line_forming_moves[color] << [line.index(pattern) + 9 - 3, i] if line.include? pattern

    pattern = "W" + color + "O" + color * 2
    self.line_forming_moves[color] << [line.index(pattern) + 9 - 2, i] if line.include? pattern

    pattern = "W" + "O" + color * 3
    self.line_forming_moves[color] << [line.index(pattern) + 9 - 1, i] if line.include? pattern

    pattern = "O" + color * 3 + "W"
    self.line_forming_moves[color] << [line.index(pattern) - 1, i] if line.include? pattern

    pattern = color + "O" + color * 2 + "W"
    self.line_forming_moves[color] << [line.index(pattern) - 2, i] if line.include? pattern

    pattern = color * 2 + "O" + color + "W"
    self.line_forming_moves[color] << [line.index(pattern) - 3, i] if line.include? pattern

    pattern = color * 3 + "O" + "W"
    self.line_forming_moves[color] << [line.index(pattern) - 4, i] if line.include? pattern

    pattern = color * 4 + "O"
    self.line_forming_moves[color] << [10 - line.index(pattern), i] if line.include? pattern
    self.line_forming_moves[color] << [10/2 - line.index(pattern), i] if line.include?(pattern) && line.index(pattern) - 1 > 0 #FIXME: This doesn't seem right

    pattern = color * 3 + "O" + color
    self.line_forming_moves[color] << [line.index(pattern) + 2, i] if line.include? pattern

    pattern = color * 2 + "O" + color * 2
    self.line_forming_moves[color] << [line.index(pattern) + 3, i] if line.include? pattern

    pattern = color + "O" + color * 3
    self.line_forming_moves[color] << [line.index(pattern) + 4, i] if line.include? pattern
  end

  def detect_diagonal_winning_move line, color, i
    pattern = "W" + color * 3 + "O"
    self.line_forming_moves[color] << [line.index(pattern) + 9 - 4, i] if line.include? pattern

    pattern = "W" + color * 2 + "O" + color
    self.line_forming_moves[color] << [line.index(pattern) + 9 - 3, i] if line.include? pattern

    pattern = "W" + color + "O" + color * 2
    self.line_forming_moves[color] << [line.index(pattern) + 9 - 2, i] if line.include? pattern

    pattern = "W" + "O" + color * 3
    self.line_forming_moves[color] << [line.index(pattern) + 9 - 1, i] if line.include? pattern

    pattern = color + "O" + color * 2 + "W"
    self.line_forming_moves[color] << [line.index(pattern) + 9 - 1, i] if line.include? pattern

    pattern = color * 2 + "O" + color + "W"
    self.line_forming_moves[color] << [line.index(pattern) + 9 - 2, i] if line.include? pattern

    pattern = color * 3 + "O" + "W"
    self.line_forming_moves[color] << [line.index(pattern) + 9 - 3, i] if line.include? pattern

    pattern = color * 4 + "O"
    self.line_forming_moves[color] << [line.index(pattern) + 9 - 4, i] if line.include? pattern
    self.line_forming_moves[color] << [line.index(pattern) - 9 - 1, i] if line.include?(pattern) && line.index(pattern) - 1 > 0

    pattern = color * 3 + "O" + color
    self.line_forming_moves[color] << [line.index(pattern) + 9 - 3, i] if line.include? pattern

    pattern = color * 2 + "O" + color * 2
    self.line_forming_moves[color] << [line.index(pattern) + 9 - 2, i] if line.include? pattern

    pattern = color + "O" + color * 3
    self.line_forming_moves[color] << [line.index(pattern) + 9 - 1, i] if line.include? pattern
  end

  def detect_reverse_diagonal_winning_move line, color, i
    pattern = "W" + color * 3 + "O"
    self.line_forming_moves[color] << [line.index(pattern) + 4, i/2 - 1] if line.include? pattern

    pattern = "W" + color * 2 + "O" + color
    self.line_forming_moves[color] << [line.index(pattern) + 3, i/2 - 2] if line.include? pattern

    pattern = "W" + color + "O" + color * 2
    self.line_forming_moves[color] << [line.index(pattern) + 2, i/2 - 3] if line.include? pattern

    pattern = "W" + "O" + color * 3
    self.line_forming_moves[color] << [line.index(pattern) + 1, i/2 - 4] if line.include? pattern

    pattern = color + "O" + color * 2 + "W"
    self.line_forming_moves[color] << [line.index(pattern), i/2 - 3] if line.include? pattern

    pattern = color * 2 + "O" + color + "W"
    self.line_forming_moves[color] << [line.index(pattern) + 9 - 2, i] if line.include? pattern

    pattern = color * 3 + "O" + "W"
    self.line_forming_moves[color] << [line.index(pattern) + 9 - 3, i] if line.include? pattern

    pattern = color * 4 + "O"
    self.line_forming_moves[color] << [line.index(pattern) + 9 - 4, i] if line.include? pattern
    self.line_forming_moves[color] << [line.index(pattern) - 9 - 1, i] if line.include?(pattern) && line.index(pattern) - 1 > 0

    pattern = color * 3 + "O" + color
    self.line_forming_moves[color] << [line.index(pattern) + 9 - 3, i] if line.include? pattern

    pattern = color * 2 + "O" + color * 2
    self.line_forming_moves[color] << [line.index(pattern) + 9 - 2, i] if line.include? pattern

    pattern = color + "O" + color * 3
    self.line_forming_moves[color] << [line.index(pattern) + 9 - 1, i] if line.include? pattern
  end
end

solver = Solver.new board
cons = solver.find_consecutives
print solver.line_forming_moves['B'].to_s + "\n"
print solver.line_forming_moves['G'].to_s + "\n"
print "#{cons['B']}\n#{cons['G']}"

__END__
require 'minitest/autorun'

class SolverTest < MiniTest::Test
  def new_board
    Array.new(10) { %w[O] * 10 }.tap {|a| a[0][0] = a[0][9] = a[9][0] = a[9][9] = "W" }
  end

  def rotate board, iterations=1
    iterations.times.map do
      board =Solver.rotate board
    end
    board
  end

  def test_horizontal_WOBBB
    board = new_board.tap { |b| b[0] = %w[W O B B B O O O O W] }
    solver = Solver.new board
    assert_equal [[0, 1]], solver.line_forming_moves['B']
  end

  def test_horizontal_WBOBB
    board = new_board.tap { |b| b[0] = %w[W B O B B O O O O W] }
    solver = Solver.new board
    assert_equal [[0, 2]], solver.line_forming_moves['B']
  end

  def test_horizontal_WBBOB
    board = new_board.tap { |b| b[0] = %w[W B B O B O O O O W] }
    solver = Solver.new board
    assert_equal [[0, 3]], solver.line_forming_moves['B']
  end

  def test_horizontal_WBBBO
    board = new_board.tap { |b| b[0] = %w[W B B B O O O O O W] }
    solver = Solver.new board
    assert_equal [[0, 4]], solver.line_forming_moves['B']
  end

  def test_horizontal_WOBBBBO
    board = new_board.tap { |b| b[0] = %w[W O B B B B O O O W] }
    solver = Solver.new board
    assert_equal [[0, 1], [0, 6], [0, 1]], solver.line_forming_moves['B']
  end

  def test_horizontal_WOOBBBBO
    board = new_board.tap { |b| b[0] = %w[W O O B B B B O O W] }
    solver = Solver.new board
    assert_equal [[0, 7], [0, 2]], solver.line_forming_moves['B']
  end

  def test_horizontal_BOBBB
    board = new_board.tap { |b| b[1] = %w[O O O B O B B B O O] }
    solver = Solver.new board
    assert_equal [[1, 4]], solver.line_forming_moves['B']
  end

  def test_horizontal_BBOBB
    board = new_board.tap { |b| b[1] = %w[O O O B B O B B O O] }
    solver = Solver.new board
    assert_equal [[1, 5]], solver.line_forming_moves['B']
  end

  def test_horizontal_BBBOB
    board = new_board.tap { |b| b[1] = %w[O O O B B B O B O O] }
    solver = Solver.new board
    assert_equal [[1, 6]], solver.line_forming_moves['B']
  end

  def test_horizontal_WOBBBBBO_empty
    skip
    board = new_board.tap { |b| b[0] = %w[W O B B B B B O O W] }
    solver = Solver.new board
    assert_equal [[]], solver.line_forming_moves['B']
  end

  def test_vertical_WOBBB
    board = rotate new_board.tap { |b| b[0] = %w[W O B B B O O O O W].reverse }, 3
    solver = Solver.new board
    assert_equal [[1, 0]], solver.line_forming_moves['B']
  end

  def test_vertical_WOBBB
    board = rotate new_board.tap { |b| b[0] = %w[W O B B B O O O O W].reverse }, 3
    solver = Solver.new board
    assert_equal [[0, 1].reverse], solver.line_forming_moves['B']
  end

  def test_vertical_WBOBB
    board = rotate new_board.tap { |b| b[0] = %w[W B O B B O O O O W].reverse }, 3
    solver = Solver.new board
    assert_equal [[0, 2].reverse], solver.line_forming_moves['B']
  end

  def test_vertical_WBBOB
    board = rotate new_board.tap { |b| b[0] = %w[W B B O B O O O O W].reverse }, 3
    solver = Solver.new board
    assert_equal [[0, 3].reverse], solver.line_forming_moves['B']
  end

  def test_vertical_WBBBO
    board = rotate new_board.tap { |b| b[0] = %w[W B B B O O O O O W].reverse }, 3
    solver = Solver.new board
    assert_equal [[0, 4]].map(&:reverse), solver.line_forming_moves['B']
  end

  def test_vertical_WOBBBBO
    board = rotate new_board.tap { |b| b[0] = %w[W O B B B B O O O W].reverse }, 3
    solver = Solver.new board
    assert_equal [[0, 1], [0, 6], [0, 1]].map(&:reverse), solver.line_forming_moves['B']
  end

  def test_vertical_WOOBBBBO
    board = rotate new_board.tap { |b| b[0] = %w[W O O B B B B O O W].reverse }, 3
    solver = Solver.new board
    assert_equal [[0, 7], [0, 2]].map(&:reverse), solver.line_forming_moves['B']
  end

  # def test_vertical_BBBOBW
  #   board = rotate new_board.tap { |b| b[0] = %w[W O O O O B B O B W].reverse }, 3
  #   solver = Solver.new board
  #   assert_equal [[0, 7]].map(&:reverse), solver.line_forming_moves['B']
  # end
  #
  # def test_vertical_BBBBOW
  #   board = rotate new_board.tap { |b| b[0] = %w[W O O O O B B B O W].reverse }, 3
  #   solver = Solver.new board
  #   assert_equal [[0, 8]].map(&:reverse), solver.line_forming_moves['B']
  # end

  def test_vertical_BOBBB
    board = rotate new_board.tap { |b| b[1] = %w[O O O B O B B B O O].reverse }, 3
    solver = Solver.new board
    assert_equal [[1, 4]].map(&:reverse), solver.line_forming_moves['B']
  end

  def test_vertical_BBOBB
    board = rotate new_board.tap { |b| b[1] = %w[O O O B B O B B O O].reverse }, 3
    solver = Solver.new board
    assert_equal [[1, 5]].map(&:reverse), solver.line_forming_moves['B']
  end

  def test_vertical_BBBOB
    board = rotate new_board.tap { |b| b[1] = %w[O O O B B B O B O O].reverse }, 3
    solver = Solver.new board
    assert_equal [[1, 6]].map(&:reverse), solver.line_forming_moves['B']
  end

  def test_vertical_WOBBBBBO_empty
    skip
    board = rotate new_board.tap { |b| b[0] = %w[W O B B B B B O O W].reverse }, 3
    solver = Solver.new board
    assert_equal [[]], solver.line_forming_moves['B']
  end
end
