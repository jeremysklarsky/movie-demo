json.name @movie.name
json.release_date @movie.release_date
json.summary @movie.summary
json.score @movie.score
json.genres @movie.genres.collect{|g|g.name}  
json.reviews @movie.reviews.sort_by{|r|r.score}.reverse do |review|
  json.critic review.critic.name
  json.score review.score
  json.excerpt review.excerpt
  json.link review.link
  json.publication review.publication.name
end





