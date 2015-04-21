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

  def truncated_name
    self.name
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

  def self.recommendation(score)
    if score == 100
      "Vincent thinks this is the best movie you've ever seen."
    elsif (score >= 95 ) && (score < 100)
      "Vincent thinks you will really, really like this movie."
    elsif (score > 90 )&& (score < 95) 
      "Vincent thinks you will really like this movie."
    elsif (score > 80 )&& (score <= 90)
      "Vincent thinks you will probably like this movie."
    elsif (score > 70 )&& (score <= 80)
      "Vincent isn't sure - you might like it, you might not."
    elsif (score > 60 )&& (score <= 70)
      "Vincent's pretty sure this movie is a waste of your time."
    else
      "Vincent is 100% you are going to HATE this movie with the passion of a thousand fiery suns."
    end
  end

end
