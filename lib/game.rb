require 'yaml'
require 'colorize'

require './board'
require './piece'

class Game
  attr_accessor :board, :players

  def players
    @players ||= [Player.new(:black), Player.new(:white)].cycle
  end
  
  def board
    @board ||= Board.new()
  end

  def play
    render
    
    puts "During the game, enter ( l ) to load and ( s ) to save a game".colorize(:red)
    puts "Press ( Enter ) to start the game."
    gets.chomp()
    
    until game_won?
      render
      process_input(self.players.next)
    end
    
    the_end_message
  end
  
  def process_input(current_player)
    previous_move = nil
    while true
      if previous_move.nil?
        previous_move = begin_sequence(current_player)
        return if previous_move.nil?
        next if previous_move.count > 1
      else
        previous_move = continue_sequence(previous_move.last, current_player)
      end
    end
  end
  
  def begin_sequence(current_player)
    while true
      print "#{current_player.name} | What piece would you like to move? "
      command = gets.chomp.split(',')
      p command
      command = save_load_begin_move(command, current_player)
      if command == :load
        return
      elsif command == :restart
        next
      else
        start_piece = command
        start_pos = start_piece.pos
        formatted_moves = start_piece.available_moves.map {|move_piece| move_piece.take(2) }
        puts "Available moves: #{formatted_moves}"

        print "#{current_player.name} | Where would you like to place the piece?"
        end_pos = gets.chomp.split(',').map(&:to_i)
        
        formatted_jumps = start_piece.available_jumps.map {|move_piece| move_piece.take(2) }
        
        if formatted_jumps.include?(end_pos)
          board.move(start_pos, end_pos)
          p "Last POS: #{end_pos}"
          formatted_jumps = start_piece.available_jumps.map {|move_piece| move_piece.take(2) }
          p "What? #{formatted_jumps}"
          
          return [end_pos] if formatted_jumps.count > 0
          return nil
          
        elsif start_piece.available_slides.include?(end_pos)
          board.move(start_pos, end_pos)
          return nil
        else
          puts "That piece can't go there. Start over!"
          next
        end
        
      end
    end
  end
  
  def continue_sequence(end_pos, current_player)
    while true
      puts "#{current_player.name} | You must take all available jumps. What piece would you like to take?"
      
      start_piece = self.board[end_pos]
      start_pos = start_piece.pos
      formatted_jumps = start_piece.available_jumps.map {|move_piece| move_piece.take(2) }
      puts "Available moves: #{formatted_jumps}"

      print "#{current_player.name} | Where would you like to place the piece?"
      end_pos = gets.chomp.split(',').map(&:to_i)

      if formatted_jumps.include?(end_pos)
        board.move(start_pos, end_pos)
        formatted_jumps = start_piece.available_jumps.map {|move_piece| move_piece.take(2) }
        p "What? #{formatted_jumps}"
        return [end_pos] if formatted_jumps.count > 1
        return nil       
      elsif start_piece.available_slides.include?(end_pos)
        board.move(start_pos, end_pos)
        return nil
      else
        puts "That piece can't go there. Start over!"
        next
      end
    end
  end
  
  def save_load_begin_move(command, current_player)
    if command[0] == ?l
      load_file
      return :load
    elsif command[0] == ?s
      save_to_yaml
      return :restart
    else
      start_pos = command.map(&:to_i)
      p start_piece = self.board[start_pos]

      if start_piece.nil?
        puts "There's no piece there. Start over!"
        return :restart
      end

      if start_piece.color != current_player.color
        puts "That piece is not yours. Start over!"
        return :restart
      end
        
      return start_piece
    end
  end
  
  def the_end_message
    render
    puts "Checkmate"
  end
  
  def render
    # system('clear')
    colors = [:light_red, :light_black]

    self.board.grid.each_with_index do |row, idx|
      row_colors = colors.reverse!.cycle

      current_row = row.map do |tile|
        color = row_colors.next

        "#{tile} ".colorize(background: color)
      end

      puts current_row.join
    end
  end

  def game_won?
    false
  end
  
  def save_to_yaml
    puts "What would you like to call your file, Mr. Putin: "
    file_name = gets.chomp
    yaml_object = self.board.to_yaml
    File.open("#{file_name}","w") {|f| f.write yaml_object }
  end

  def load_file
    puts "Enter the name of the file, Mr. Putin: "
    self.board = YAML::load_file(gets.chomp)
    render
  end
  
end

class Player
  attr_accessor :name, :color

  def initialize(color)
    self.color = color
  end
  
  def name
    @name ||= get_name
  end

  def get_name
    puts "#{self.color.to_s.upcase} Player| What is your name?"
    gets.chomp()
  end

end

Game.new.play