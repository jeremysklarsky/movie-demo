desc "Add Similarity Scores of existing users to db"
task :similarity_score => :environment do

  User.all.each do |user|
    critics = user.gather_critics
    
    critics.each do |critic|
      @score = SimilarityScore.new
      @score.similarity_score = user.similarity_score(critic)
      @score.critic_id = critic.id
      @score.user_id = user.id
      @score.review_count = user.critic_matcher.common_movies(critic).size
      @score.save
    end

  end
end

