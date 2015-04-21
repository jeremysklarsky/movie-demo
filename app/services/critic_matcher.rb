class CriticMatcher

  attr_reader :user, :movies, :all_stats

  def initialize(user)
    @user = user
    @movies = user.movies
  end
 

  def find_user_critics
    @user_critics = movies.collect{|movie|movie.critics}.flatten.uniq
    @user_critics
  end

  def all_stats
  # builds hash with similarity scores, overlap %
    all_stats_hash = {}
    movies.collect{|movie|movie.critics}.flatten.uniq.each do |critic|
      all_stats_hash[critic] = {:name => (critic.name || critic.publications.first.name), :similarity_score => @user.similarity_score(critic), :common_reviews => common_movies(critic).size, :overlap => @user.critic_overlap(critic) }
    end
    all_stats_hash    
  end

  def critics_list  
    all_stats.collect do |critic, stats|
      [critic.name, stats[:similarity_score]]
    end
  end



  def common_movies(critic)
    # returns array of movies both user and critic have reviewed
    @movies.select do |movie|
      movie if movie.critics.include?(critic) 
    end
  end

end