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

  def recent_reviews

    if self.movies.size >=3
      CriticReview.where(critic_id: self.id, movie_id: [self.movies.sort_by{|movie|movie.release_date}[-3..-1].collect{|movie|movie.id}])
    else
      CriticReview.where(critic_id: self.id)
    end

  end

  def reviews_by_genre
    reviews_hash = Hash.new { |h, k| h[k] = [] }
    self.reviews.each do |review|
      review.movie.genres.each do |genre|
        reviews_hash[genre] << review
      end
    end
    reviews_hash
  end

  def review_count_by_genre
    count_hash = Hash.new(0)
    reviews_by_genre.each do |genre, reviews|
      count_hash[genre.name] = reviews.size
    end
    count_hash.sort_by {|_key, value| value}.reverse.to_h
  end

  def avg_score_by_genre
    avg_scores = Hash.new(0)
    reviews_by_genre.each do |genre, reviews|
      avg_scores[genre.name] = (reviews.collect{|review|review.score}.inject(:+)/reviews.size.to_f).round(1)
    end
    avg_scores.sort_by {|_key, value| value}.reverse.to_h
  end

end


