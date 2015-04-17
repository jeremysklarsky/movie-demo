class CriticMatcher

  attr_reader :user, :movies

  def initialize(user)
    @user = user
    @movies = user.movies
  end
 
  def find_user_critics
    @user_critics = movies.collect{|movie|movie.critics}.flatten.uniq
    @user_critics
  end

  def find_top_critic
    rank_critics.first
  end

  def rank_critics
    critics = find_user_critics.select{|critic|critic.shared_reviews(@user).
      size >= 3 }
    critics.sort_by{|critic|user.similarity_score(critic)}.reverse
  end

  def common_movies(critic)
    # returns array of movies both user and critic have reviewed
    @movies.select do |movie|
      movie if movie.critics.include?(critic) 
    end
  end

end