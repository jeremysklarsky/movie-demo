class SearchController < ApplicationController

  def new
    @user = current_user
  end

  def create
    binding.pry
    @movies = Movie.where("name like ?", "%#{params[:query]}%")

    respond_to do |f|
      f.js
    end
  end

  def show

  end

end