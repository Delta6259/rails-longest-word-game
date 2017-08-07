class GamesController < ApplicationController
  def game
   @grid = generate_grid(9)
   @start = Time.now
  end

  def score
    @try = params[:try]
    @start = Time.parse(params[:start]).to_i
    @end = Time.now.to_i
    @grid = params[:grid]
    @time_taken = @end - @start
    compute_score(@try, @time_taken)
    run_game(@try, @grid, @start, @end)
    score_and_message(@try, @grid, @time_taken)
  end

  private

  def generate_grid(grid_size)
    Array.new(grid_size) { ('A'..'Z').to_a.sample }
  end

  def included?(guess, grid)
    guess.chars.all? { |letter| guess.count(letter) <= grid.count(letter) }
  end

  def compute_score(attempt, time_taken)
    time_taken > 60.0 ? 0 : attempt.size * (1.0 - time_taken / 60.0)
  end

  def run_game(attempt, grid, start_time, end_time)
    result = { time: end_time - start_time }
    score_and_message = score_and_message(attempt, grid, result[:time])
    result[:score] = score_and_message.first
    result[:message] = score_and_message.last

    result
  end

  def score_and_message(attempt, grid, time)
    if included?(attempt.upcase, grid)
      if english_word?(attempt)
        score = compute_score(attempt, time)
        @score =[score, "well done"]
      else
        @score = [0, "not an english word"]
      end
    else
      @score = [0, "not in the grid"]
    end
  end

  def english_word?(word)
    response = open("https://wagon-dictionary.herokuapp.com/#{word}")
    json = JSON.parse(response.read)
    return json['found']
  end


end
