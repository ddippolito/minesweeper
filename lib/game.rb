class Game
  attr_accessor :dimension

  def initialize(dimesion)
    @dimension = dimension
  end

  def build_board(dimension)
    Board.new(dimension)
  end
end
