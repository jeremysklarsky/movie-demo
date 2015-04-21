class UsersController < ApplicationController

    before_action :set_user, only: [:show]

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      login(@user)
      redirect_to user_path(@user)
    else
      render 'new'
    end
  end

  def show
    @movies = current_user.movies.sort_by{|movie|movie.name}
    @fact = MovieFact.all.sample.content
  end

  def stats
    @user = current_user
    if @user.movies.size > 5
      @top_critic = @user.top_critic
      @bottom_critic = @user.bottom_critic
      @user_reviews = @user.reviews
      @top_rated_movie = @user.top_rated_movie
      @bottom_rated_movie = @user.bottom_rated_movie
    end
  end

  private
  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end

  def set_user
    @user = User.find(params[:id])
  end
end
