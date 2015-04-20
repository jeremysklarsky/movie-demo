class User < ActiveRecord::Base
  validates_uniqueness_of :email
  validates_presence_of :name, :email
  validates_format_of :email, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i
  has_secure_password
  validates :password, 
         # you only need presence on create
         :presence => { :on => :create },
         # allow_nil for length (presence will handle it on create)
         :length   => { :minimum => 6, :allow_nil => true },
         # and use confirmation to ensure they always match
         :confirmation => true

  has_many :reviews, :foreign_key => 'user_id', :class_name => "UserReview"
  has_many :movies, :through => :reviews
  
  include Averageable::InstanceMethods




  def gather_critics
    critic_matcher.find_user_critics
  end

  def get_relevant_critics(movie)
    gather_critics.select{|critic|critic.movies.include?(movie)}
  end 

  def similarity_score(critic)
    
    user_movie_ids = self.movies.collect{|movie| movie.id}
    critic_reviews = CriticReview.where(movie_id: user_movie_ids, critic_id: critic.id ).select{|review|user_movie_ids.include?(review.movie_id)}
    user_reviews = UserReview.where(user_id: self.id, movie_id: user_movie_ids)
    differences = []
    critic_reviews.each do |review|
      differences << (review.score - user_reviews.select{|r|r.movie_id == review.movie_id}.first.score).abs
    end
    (100 - (differences.inject(:+) / differences.size.to_f)).round(2)

  end

  def critic_overlap(critic)
    critic_matcher.common_movies(critic).size / self.movies.size.to_f
  end

  def critic_overlap_weighted(critic)
    if critic_overlap(critic) <= 0.1
      critic_overlap(critic)
    else
      Math.log10(critic_overlap(critic)).round(2) + 1  
    end
  end

  def adjusted_score(movie)
    # {critic => similarity_score}
    critic_hash = {}
    # credits
    total_overlap_points = 0
    # grade_sum
    total_score = 0 
    get_relevant_critics(movie).each do |critic|
    # get similarity scores for each critic
      overlap = critic_overlap_weighted(critic)
      sim_score = similarity_score(critic) / 100.0
      critic_hash[critic] = {:similarity => sim_score, :overlap => overlap }
      total_overlap_points += overlap
    # calculate total overlap points (total credits)
      total_score += (critic.get_review(movie))*overlap
    end
    # sum and divide (GPA)
    (total_score / total_overlap_points.to_f).round(2)
  end

  def my_score(movie)
    if self.movies.include?(movie)
      UserReview.find_by(user_id: self.id, movie_id: movie.id).score
    end
  end


  def average_similarity_score
    (gather_critics.collect{|critic|self.similarity_score(critic)}.inject(:+) / gather_critics.size.to_f).round(2)
  end

  def average_similarity_score_std_dev
    gather_critics.collect{|critic|self.similarity_score(critic)}.standard_deviation.round(2)
  end

  def stats_call
    
  end

  def get_stats
    @stats = critic_matcher.get_stats
  end

  def top_critic
      
  end

  

  private

  def critic_matcher
    CriticMatcher.new(self)
  end



end




