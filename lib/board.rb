require './piece.rb'

class Board
  attr_accessor :grid
  SIZE = 8
  
  def initialize(other_grid = nil)
    self.grid = other_grid if grid
  end

  def grid
    @grid ||= Array.new(SIZE) { Array.new(SIZE) }.tap do |grid|
      [:black, :white].each do |color|
        start_index = (color == :black) ? 0 : 5
        
        (0...3).each do |add_row|
          current_index = start_index + add_row
          grid[current_index] = fill_row(color, current_index)
        end
      end
    end
  end
  
  def fill_row(color, r)
    [].tap do |row_array| 
      (0...SIZE).each do |c|
        row_array << (((c + (r % 2)) % 2) == 0 ? Piece.new(self, [r, c], color) : nil)
      end
    end
  end
  
  def move(start_pos, end_pos)
    move!(start_pos, end_pos) # if valid_move?(start_pos, end_pos)
  end
  
  def move!(start_pos, end_pos) 
    piece = self[start_pos]
    
    if piece.available_slides.include?(end_pos)
      piece.perform_slide(end_pos)
    elsif piece.available_jumps.map {|move_piece| move_piece.take(2) }.include?(end_pos)
      piece.perform_jump(end_pos)
    else
      puts "Where did you get this position!?!?"
    end
  end

  def [](pos)
    self.grid[pos[0]][pos[1]]
  end

  def []=(pos, value)
    self.grid[pos[0]][pos[1]] = value
  end
  
  
  def deep_dup
    new_board = Board.new(Array.new(SIZE) { Array.new(SIZE) })
    (team_pieces(:black) + team_pieces(:white)).each do |piece|
      new_board[piece.pos] = piece.dup(new_board)
    end
    new_board
  end
    
end