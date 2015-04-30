json.name (@critic.name)

json.reviews @critic.reviews.sort_by{|r|r.movie.name} do |review|
  json.movie review.movie.name
  json.score review.score
  json.excerpt review.excerpt
  json.link review.link
  json.publication review.publication.name
end

json.stats do 
  json.average_score @critic.avg_score
  json.scores_by_genre @critic.avg_score_by_genre
  json.reviews_by_genre @critic.review_count_by_genre
end 
