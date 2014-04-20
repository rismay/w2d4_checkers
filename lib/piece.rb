class Piece
  attr_accessor :board, :promoted, :color, :pos
  
  DELTA_Y = [[1, 1], [1, -1]] #This is prior to promotion
  DELTA_X = [[1, 1], [1, -1], [-1, 1], [-1, -1]] #This is after promotion
  
  def initialize(board, s_pos, color, promoted = false)
    self.board, self.pos, self.color = board, s_pos, color
    @promoted = promoted
  end
  
  def promoted?
    @promoted
  end
  
  def pos=(new_pos)
    @pos = new_pos
    self.promoted = (self.pos[0] == (self.color == :black ? 7 : 0))
  end
  
  def delta
    if self.promoted
      if (self.color == :black)
        DELTA_X
      else
        DELTA_X.map{ |x, y| [x * (-1), y * (-1)] }
      end      
    else
      if (self.color == :black)
        DELTA_Y
      else
        DELTA_Y.map{ |x, y| [x * (-1), y * (-1)] }
      end
    end
  end
  
  def enemy?(enemy)
    self.color != enemy.color
  end

  def in_board?(pos)
    pos[0].between?(0,7) && pos[1].between?(0,7)
  end
  
  def dup(board)
    dup_piece = self.class.new(board, self.pos.dup, self.color)
    dup_piece.promoted = self.promoted
    dup_piece
  end
  
  def available_moves
    available_slides + available_jumps
  end

  def available_slides
    [].tap do |moves_array|
      delta.each do |dx, dy|
        x, y = self.pos
        new_pos = [x + dx, y + dy]
        if in_board?(new_pos)
          piece = board[new_pos]
          moves_array << new_pos if piece.nil?
        end
      end
    end
  end
  
  def available_jumps
    [].tap do |moves_array|
      delta.each do |dx, dy|
        x, y = self.pos
        new_pos = [x + dx, y + dy]
        if in_board?(new_pos)
          piece = board[new_pos]
          if !piece.nil? && enemy?(piece)
            nx, ny = new_pos
            new_pos = [nx + dx, ny + dy, piece]
            p moves_array << new_pos if board[new_pos].nil? &&  in_board?(new_pos)       
          end
        end
      end
    end
  end
  
  def perform_slide(new_pos)
    self.board[self.pos] = nil
    self.pos = new_pos
    self.board[new_pos] = self
  end
  
  def perform_jump(end_pos)
    p jumps = available_jumps
    index = jumps.map { |triple | triple.take(2) }.index(end_pos)
    p pos_piece = jumps[index]    #Get the piece jumped
    p enemy_piece = pos_piece[2]
    self.board[enemy_piece.pos] = nil     #Remove enemy from the board
    self.board[pos] = nil #Remove the moving piece from the board
    new_pos = pos_piece[0..1]    #Get new POS
    self.pos = new_pos     #Set Self to new POS
    self.board[new_pos] = self     #Tell the board that I am there
  end
  
  def inspect
    self.pos.join(", ")
  end
  def to_s
    return self.pos.to_s.colorize(:black) if self.color == :black
    return self.pos.to_s.colorize(:white) if self.color == :white
    # self.color.to_s
    #return (self.promoted? ? "\u26C2" : "\u26C3").colorize(:black) if self.color == :black
    #return (self.promoted? ? "\u26C1" : "\u26C0").colorize(:white) if self.color == :white
  end
end

class NilClass
  def to_s
    "[ ,  ] "
  end
end