class UserReview < ActiveRecord::Base
  belongs_to :user
  belongs_to :movie

  after_save :update_similarity_score

  def update_similarity_score
    user = self.user
    critics = self.movie.critics  
    critics.each do |critic|
      score = SimilarityScore.find_or_create_by(user_id: user.id, critic_id: critic.id)
      score.similarity_score = user.similarity_score(critic)
      score.critic_id = critic.id
      score.user_id = user.id
      score.review_count = user.critic_matcher.common_movies(critic).size
      score.save
    end


  end


end
