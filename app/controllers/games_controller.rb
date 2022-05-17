require 'open-uri'
require 'json'

class GamesController < ApplicationController
  def guess
    @number = (9..15).to_a.sample
    @grid = generate_grid(@number)
  end

  def result
    @end_time = Time.now
    @results = run_game(params[:guess], params[:grid].split(''), params[:start_time].to_datetime, @end_time)
    session[:score] = session[:score] || []
  end

  def generate_grid(grid_size)
    @generated_grid = []
    i = 0
    until i == grid_size
      @generated_grid << (('A'..'Z').to_a.sample)
      i += 1
    end
    @generated_grid
  end

  def run_game(attempt, grid, start_time, end_time)
    # TODO: runs the game and return detailed hash of result (with `:score`, `:message` and `:time` keys)
    url = "https://wagon-dictionary.herokuapp.com/#{attempt}"
    api = JSON.parse(URI.open(url).read)
    if api['found'] == false
      r = { score: 0, message: 'Not an english word', time: end_time - start_time }
    elsif !attempt.upcase.chars.all? { |c| grid.count(c) >= attempt.upcase.count(c) }
      r = { score: 0, message: 'Not in the grid', time: end_time - start_time }
    elsif attempt.upcase.chars.all? { |c| grid.include?(c) }
      r = { score: attempt.length * 10 + (100 - (end_time - start_time)), message: 'Well done', time: end_time - start_time }
    end
    r
  end
end
