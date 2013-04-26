require 'spec_helper'

class Minesweeper
end


class SolutionGenerator

  def initialize(dimension, bombs)
    @dimension = dimension
    @bombs = bombs
  end

  def solution
    cells.each_slice(dimension).collect { |cell| cell }
  end

  private

  def total
    dimension * dimension
  end

  def cells
    (empty_cells + exploding_cells).shuffle
  end

  def empty_cells
   (total - bombs).times.collect { Cell.empty }
  end

  def exploding_cells
    bombs.times.collect { Cell.exploding }
  end

  attr_reader :dimension, :bombs
end

class Grid

  def initialize(dim, bombs=2)
    @dim = dim
    @bombs = bombs
  end

  attr_reader :bombs

  def score(x, y)
    neighbours(x,y).count(&:bomb?)
  end

  def cell(x, y)
    x >= 0 && x < dim && y >= 0 && y < dim ? Some[cells[x][y]] : None
  end

  def cells
    @cells ||= SolutionGenerator.new(dim, bombs).solution
  end

  private

  def neighbours(x, y)
    [
      [x - 1, y - 1],
      [x - 1, y + 1],
      [x - 1, y    ],
      [x    , y - 1],
      [x    , y + 1],
      [x + 1, y - 1],
      [x + 1, y + 1],
      [x + 1, y    ]
    ].flat_map { |(x,y)| cell(x, y) }
  end

  attr_reader :dim
end

describe Grid do

  let (:grid)      { Grid.new(dimension, bombs) }
  let (:dimension) { 4 }
  let (:bombs)     { 3 }

  describe "#cell" do
    it 'returns an Option[Cell]' do
      grid.cell(0,0).should be_some Cell
    end
  end

  it 'takes a dimension and a number of bombs' do
    grid.bombs.should eq 3
  end

  it 'creates a grid of cells based on the dimension' do
    grid.cells.flatten.count.should eq (dimension * dimension)
  end

  it 'should have the same no of exploding cells as bombs' do
    grid.cells.flatten.select(&:bomb?).count.should eq bombs
  end

  describe "#score" do
    it 'should be 0 if there are no bombs' do
      Grid.new(1, 0).score(0,0).should be_zero
    end

    it 'should be 1 if it has a bomb in a cell next to ' do
      grid = Grid.new(2,1)

      grid.stub(cells: [[Cell.exploding,  Cell.empty],
                        [Cell.empty,      Cell.empty]] )

      grid.score(0,1).should eq 1
      grid.score(1,0).should eq 1
      grid.score(1,1).should eq 1
    end

    it 'should be 2 if there are two bombs adjacent to the cell' do
      grid = Grid.new(2,2)

      grid.stub(cells: [[Cell.exploding,  Cell.empty],
                        [Cell.exploding,  Cell.empty]] )

      grid.score(0,1).should eq 2
      grid.score(1,1).should eq 2
    end

    it 'should work for other number of bombs' do
      grid = Grid.new(3,3)

      grid.stub(cells: [[Cell.exploding,  Cell.empty, Cell.empty],
                        [Cell.exploding,  Cell.empty, Cell.empty],
                        [Cell.exploding,  Cell.empty, Cell.empty]])

      grid.score(0,1).should eq 2
      grid.score(1,1).should eq 3
      grid.score(2,1).should eq 2
      grid.score(0,2).should eq 0
      grid.score(1,2).should eq 0
      grid.score(2,2).should eq 0
    end
  end

end

class Cell

  def initialize(bomb)
    @bomb = bomb
  end

  def bomb?
    bomb.some?
  end

  private

  attr_reader :bomb

  def self.exploding
    Cell.new(Some[Bomb])
  end

  def self.empty
    Cell.new(None)
  end

end

module Bomb
  extend self
end

describe Cell do
  it 'knows if it has a bomb' do
    Cell.exploding.should be_bomb
  end

  it "knows if it doesn't a bomb" do
    Cell.empty.should_not be_bomb
  end
end
