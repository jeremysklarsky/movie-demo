class Genre < ActiveRecord::Base
  has_many :movie_genres
  has_many :movies, :through => :movie_genres

  include Averageable::InstanceMethods

  def reviews
    self.critic_reviews
  end

end
