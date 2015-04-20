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
  end

  def stats
    @critic_matcher = CriticMatcher.new(current_user)
    @stats = @critic_matcher.critics_list
  end

  private
  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end

  def set_user
    @user = User.find(params[:id])
  end
end
