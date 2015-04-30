class CriticsController < ApplicationController

  def index
    @critics = Critic.all.reject{|critic|critic.name==nil}.sort_by{|critic|critic.name}
    respond_to do |f|
      f.html
      f.json { render json: @critics, status: 200 }
    end
  end

  def show
    @critic = Critic.find_by_slug(params[:id])
    @user = current_user
    @recent_reviews = @critic.recent_reviews
    if current_user
      @similarity_score = @user.find_similarity_score(@critic)
      @review_count = @user.get_review_count(@critic)
    end
    respond_to do |f|
      f.html
      f.json { render :partial => "critics/show.json" }
    end
  end
end