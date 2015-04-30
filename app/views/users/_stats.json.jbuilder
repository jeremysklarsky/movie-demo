json.name (@user.name)

json.stats do 
  json.average_score @user.avg_score
  json.scores_by_genre @user.avg_score_by_genre
  json.reviews_by_genre @user.review_count_by_genre
end 

json.reviews @user.reviews.sort_by{|r|r.movie.name} do |review|
  json.movie review.movie.name
  json.score review.score
end

json.similarity_scores @user.similarity_scores do |score|
  json.critic score.critic.name
  json.similarity_score score.similarity_score
  json.review_count score.review_count
end