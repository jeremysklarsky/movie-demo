class MoviesController < ApplicationController

  def index 
    @movies = Movie.all.sort_by{|movie|movie.name}
  end

  def show
    @movie = Movie.find(params[:id])
    @user = current_user
    if UserReview.find_by(user_id: @user.id, movie_id: @movie.id)
      @user_review = UserReview.find_by(user_id: @user.id, movie_id: @movie.id)
    end
  end

end