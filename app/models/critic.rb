class Critic < ActiveRecord::Base
  
  extend Averageable::ClassMethods
  include Averageable::InstanceMethods

  has_many :critic_publications
  has_many :publications, :through => :critic_publications

  has_many :critic_reviews
  has_many :movies, :through => :critic_reviews

  def reviews
    self.critic_reviews
  end

  def shared_reviews(user)
    self.movies.select{|movie|user.movies.include?(movie)} 
  end

  def get_review(movie)
    movie.critic_reviews.find{|critic_review| critic_review.critic == self}.score
  end

end


