require 'rspec'

describe Game do

  before do
    @game = Game.new
  end

  it 'should play' do
    Game.should respond_to(:play)
  end

end