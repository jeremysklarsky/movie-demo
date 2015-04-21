class SearchController < ApplicationController

  def new
    @user = current_user
  end

  def create
    @movies = Movie.where("name like ?", "%#{params[:query]}%")

    respond_to do |f|
      f.js
    end
  end

  def show

  end

  def critics
    @critics = Critic.where("name like ?", "%#{params[:query]}%")

    respond_to do |f|
      f.js
    end

  end

end