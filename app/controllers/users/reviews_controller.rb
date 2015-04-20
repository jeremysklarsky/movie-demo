class Users::ReviewsController < ApplicationController

  autocomplete :movies, :name

  # def autocomplete_name
  #   binding.pry
  #   @movies = Movie.order(:name).where("name LIKE ?", "#{params[:term]}%").limit(6)
  #     respond_to do |format|
  #     format.html
  #     format.json { 
  #       render json: @movies.map(&:name)
  #     }
  #   end
  # end
  def index
    @user = current_user
    @movies = @user.movies
  end


  def create
    @user_review = UserReview.new(user_review_params)
    @user_review.user = User.find(params[:user_id])
    @user_review.save
    redirect_to '/'
  end

  def update
    # binding.pry
    @user_review = UserReview.find(params[:id])
    @user_review.score = params[:review][:score]
    @movie = @user_review.movie
    @user_review.save
    respond_to do |f|
      f.js
    end
  end

  def edit
    # binding.pry
    @user = current_user  
    @user_review = UserReview.find(params[:id])
    @movie = @user_review.movie
    respond_to do |f|
      f.js
    end
  end

  private

  def user_review_params
    params.require(:review).permit(:movie_id, :score)
  end

end
