class User < ActiveRecord::Base
  # has_secure_password
  
  has_many :reviews, :foreign_key => 'user_id', :class_name => "UserReview"
  has_many :movies, :through => :reviews
  
  include Averageable::InstanceMethods


  def gather_critics
    critic_matcher.find_user_critics
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
    Math.log10(critic_overlap(critic)).round(2) + 1
  end

  def adjusted_score(movie)
     
    # {critic => similarity_score}
    critic_hash = {}
    total_overlap_points = 0
    total_score = 0
    gather_critics.each do |critic|
    # get similarity scores for each critic
    overlap = critic_overlap_weighted(critic)
    points = similarity_score(critic) / 100.0
      critic_hash[critic] = {:similarity => points, :overlap => overlap }
      total_overlap_points += overlap
      total_score += (points * critic.get_review(movie) * overlap)  
    end
  
    # calculate total overlap points (total credits)

    (total_score / total_overlap_points.to_f).round(1)
    # sum and divide (GPA)
  end


  private

  def critic_matcher
    CriticMatcher.new(self)
  end



end




