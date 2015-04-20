class Critic < ActiveRecord::Base
  
  extend Averageable::ClassMethods
  include Averageable::InstanceMethods

  has_many :critic_publications
  has_many :publications, :through => :critic_publications

  has_many :critic_reviews
  has_many :movies, :through => :critic_reviews

  def name_show
    self.name.present? ? self.name : "<uncredited>"
  end


  def reviews
    self.critic_reviews
  end

  def shared_reviews(user)
    self.movies.select{|movie|user.movies.include?(movie)} 
  end

  def get_review(movie)

    # review = movie.critic_reviews.find{|critic_review| critic_review.critic == self}
    sql = "SELECT * FROM critic_reviews WHERE critic_reviews.critic_id = #{self.id} AND critic_reviews.movie_id = #{movie.id}"

    review = ActiveRecord::Base.connection.execute(sql).first
    review["score"] if review
  end

  def self.average_score
    sql = "select avg(score) from critic_reviews"
    result = ActiveRecord::Base.connection.execute(sql)
    result.first[0].round(2)
  end

end


