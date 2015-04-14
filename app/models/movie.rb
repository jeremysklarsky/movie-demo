class Movie < ActiveRecord::Base
  has_many :user_reviews
  has_many :users, :through => :user_reviews
  has_many :critic_reviews  
  has_many :critics, :through => :critic_reviews

  has_many :movie_genres
  has_many :genres, :through => :movie_genres
  
  include Averageable::InstanceMethods

  def to_slug
    self.metacritic_url.gsub("/", "%2F").gsub(":", "%3A")
  end

  def reviews
    self.critic_reviews
  end

  def critics
    self.reviews.collect{|review| review.critic}
  end

  def self.avg_score_list
    order("score DESC")
  end

  def find_review(reviewer)
    if reviewer.is_a?(User)
      UserReview.where(["movie_id = ? and user_id = ?", self.id, reviewer.id]).first
    elsif reviewer.is_a?(Critic)
      CriticReview.where(["movie_id = ? and critic_id = ?", self.id, reviewer.id]).first
    end
  end

  def user_avg
    if self.user_reviews.size > 0
      self.user_reviews.collect{|review| review.score}.inject(:+) / self.user_reviews.size.to_f 
    else
      "No users have reviewed this film."
    end
  end

end
