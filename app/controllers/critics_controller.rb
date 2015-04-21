class CriticsController < ApplicationController

  def index
    @critics = Critic.all.reject{|critic|critic.name==nil}.sort_by{|critic|critic.name}
  end

  def show
    @critic = Critic.find(params[:id])
    @user = current_user
    @recent_reviews = @critic.recent_reviews
    @similarity_score = @user.find_similarity_score(@critic)
    @review_count = @user.get_review_count(@critic)
  end

end