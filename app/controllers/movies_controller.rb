class MoviesController < ApplicationController

  # before_action :login_required

  def index 
    @movies = Movie.all.sort_by{|movie|movie.name}
    respond_to do |f|
      f.html
      f.json { render json: @movies, status: 200}
    end
  end

  def show
    @movie = Movie.find_by_slug(params[:id])
    if current_user
      @user = current_user
      @user_review = UserReview.find_by(user_id: @user.id, movie_id: @movie.id)
      @critics = @user.get_relevant_critics(@movie) #|| @movie.critics.sample
      @adjusted_score = @user.adjusted_score(@movie)
      @top_critic = @critics.sort_by{|critic|@user.similarity_score(critic)}.reverse.first || @movie.critics.sample
      @top_critic_similarity_score = @user.find_similarity_score(@top_critic) if !@user.movies.empty?
      @featured_review = CriticReview.find_by(critic_id: @top_critic.id, movie_id:@movie.id) if @top_critic
    end
    respond_to do |f|
      f.html
      f.json { render :partial => "movies/show.json" }
    end

  end

end