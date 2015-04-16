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

  def top_critic
    critic_matcher.find_top_critic
  end

  def similarity_score(critic)
    movies = critic_matcher.common_movies(critic)
    scores_set = []
    movies.each do |movie|
      
     scores_set << [movie.find_review(self).score, movie.find_review(critic).score]
   end

   avg_difference = scores_set.collect{|set| (set[0]-set[1]).abs}.inject(:+) / movies.size.to_f
   
   (100 - avg_difference).round(2)
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
      total_score += (critic.get_review(movie))*overlap
    end
  
    # calculate total overlap points (total credits)

    (total_score / total_overlap_points.to_f).round(2)
    # sum and divide (GPA)
  end

  def my_score(movie)
    if self.movies.include?(movie)
      UserReview.find_by(user_id: self.id, movie_id: movie.id).score
    end
  end



  

  private

  def critic_matcher
    CriticMatcher.new(self)
  end



end




