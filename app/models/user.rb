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
  has_many :similarity_scores
  
  include Averageable::InstanceMethods

  attr_accessor :top_critic, :bottom_critic, :avg_percentile


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

  def find_similarity_score(critic)
    @sim_score = SimilarityScore.where(user_id: self.id, critic_id: critic.id)
    if !@sim_score.empty?
      @sim_score.first.similarity_score
    end
  end 

  def critic_overlap(critic)
    @sim_score = SimilarityScore.where(critic_id: critic.id, user_id: self.id)
    if !@sim_score.empty?
      @sim_score.first.review_count / self.movies.size.to_f
    else
      0
    end

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
    movie.critics.each do |critic|
    # get similarity scores for each critic
      score = SimilarityScore.where(critic_id: critic.id, user_id: self.id)
      overlap = critic_overlap_weighted(critic)  
      if !score.empty?
        sim_score = score.first.similarity_score / 100.0
      else
        sim_score = 0
      end

      critic_hash[critic] = {:similarity => sim_score, :overlap => overlap }
      total_overlap_points += overlap
    # calculate total overlap points (total credits)
      total_score += (critic.get_review(movie))*overlap
    end
    # sum and divide (GPA)
    score = (total_score / total_overlap_points.to_f).round(2)
    if score > 0 
      score
    else
      "Sorry, Vincent needs more vodka and fireworks to figure this out."
    end
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

  def get_stats
    @stats = critic_matcher.get_stats
  end

  def top_critic
    Critic.find(SimilarityScore.where(user_id: self.id).sort_by{|sim|sim.similarity_score}.reject{|r|r.review_count < 4 }.reverse.first.critic_id)
  end

  def bottom_critic
    Critic.find(SimilarityScore.where(user_id: self.id).sort_by{|sim|sim.similarity_score}.reject{|r|r.review_count < 5 }.first.critic_id)
  end

  def top_rated_movie
    Movie.find(self.reviews.sort_by{|review|review.score}.reverse.first.movie_id)
  end

  def bottom_rated_movie
    Movie.find(self.reviews.sort_by{|review|review.score}.first.movie_id)
  end

  def top_critic_similarity
    self.similarity_score(top_critic)
  end

  def bottom_critic_similarity
    self.similarity_score(bottom_critic)
  end

  def critic_matcher
    CriticMatcher.new(self)
  end

  def self.average_score
    sql = "select avg(score) from user_reviews"
    result = ActiveRecord::Base.connection.execute(sql)
    result.first[0].round(2)
  end

  def update_similarity_score(critic, critic_review, user_review)
    @similarity_score = self.similarity_scores.find_by(:critic_id => critic.id)
    new_value = (critic_review.score - user_review.score).abs
    total_values = @similarity_score.similarity_score * @similarity_score.review_count
    @similarity_score.review_count += 1
    total_values += new_value
    @similarity_score.similarity_score = total_values / @similarity_score.review_count
    @similarity_score.save
  end

  def avg_percentile_critics(average)

    sql = "SELECT critics.name, COUNT(*) as review_count, AVG(score) as average 
      FROM critics 
      JOIN critic_reviews ON critics.id = critic_reviews.critic_id 
      GROUP BY critics.name 
      HAVING review_count > 10
      ORDER BY average DESC"

    results = ActiveRecord::Base.connection.execute(sql)
    
    (results.select{|critic|critic[2]>average}.size / results.select{|critic|critic[2]}.size.to_f).round(1)
  end

  def avg_percentile_critics_show
    percentile = self.avg_percentile_critics(self.avg_score)
    if percentile <= 0.50
      "This is higher than #{(1-percentile)*100}% of critics."
    else
      "This is lower than #{(1-percentile)*100}% of critics."
    end

  end

  def avg_percentile_users(average)

    sql = "SELECT users.name, COUNT(*) as review_count, AVG(score) as average 
      FROM users 
      JOIN user_reviews ON users.id = user_reviews.user_id 
      GROUP BY users.name 
      HAVING review_count > 10
      ORDER BY average DESC"

    results = ActiveRecord::Base.connection.execute(sql)
    
    (results.select{|user|user[2]>average}.size / results.select{|user|user[2]}.size.to_f).round(1)
  end

  def avg_percentile_users_show
    percentile = self.avg_percentile_users(self.avg_score)
    if percentile <= 0.50
      "Your average is score is higher than #{(1-percentile)*100}% of users."
    else
      "Your average is score than #{(1-percentile)*100}% of users."
    end

  end


end




