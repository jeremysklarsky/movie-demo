class Users::ReviewsController < ApplicationController

  def index
    @user = current_user
    @movies = @user.movies
  end


  def create
    @user_review = UserReview.new(user_review_params)
    @user_review.user = User.find_by_slug(params[:user_id])
    @user = @user_review.user
    @user_review.save
    redirect_to user_reviews_path(@user)
  end

  def update
    @user_review = UserReview.find(params[:id])
    @user_review.score = params[:review][:score]
    @movie = @user_review.movie
    @user = @user_review.user
    @user_review.save
    respond_to do |f|
      f.js
    end
  end

  def edit
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
