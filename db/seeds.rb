# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

# 1. Gather list of movies
twenty_fourteen_movies_two = ["It Felt Like Love","Housebound","The Dog","The Guest","Vic + Flo Saw a Bear","The Lunchbox","Horses of God","Afternoon of a Faun: Tanaquil Le Clercq","Wild","Listen Up Philip","Obvious Child","How to Train Your Dragon 2","Guardians of the Galaxy","The Dance of Reality","Nightcrawler","Happy Valley","Kids for Cash","Aatsinki: The Story of Arctic Cowboys","Waiting for August","Frank","The Retrieval","The Trip to Italy","Honey","Goodbye to Language 3D","Night Moves","The Kingdom of Dreams and Madness","The Battered Bastards of Baseball","Rich Hill","2 Autumns, 3 Winters","Plot for Peace","The Great Flood","Omar","The Skeleton Twins","Dancing in Jaffa","The Vanquishing of the Witch Baba Yaga","X-Men: Days of Future Past","Unrelated","Finding Vivian Maier","Bad Hair","Interstellar","Big Hero 6","Whitey: United States of America v. James J. Bulger","Joe","Like Father, Like Son","A Field in England","A Most Wanted Man","The Imitation Game","Ai Weiwei: The Fake Case","Cheatin'","Beyond the Lights","Once Upon a Time Verônica","Le Week-End","Mistaken for Strangers","Little Feet","Witching and Bitching","Cold in July","A Picture of You","American Sniper","Diplomacy","True Son","In Bloom","The Blue Room","7 Boxes","Exhibition","The Rocket","A People Uncounted","Gore Vidal: The United States of Amnesia","Violette","When I Saw You","The Great Invisible","Brothers Hypnotic","The Way He Looks","The Theory of Everything","The Internet's Own Boy: The Story of Aaron Swartz","The Heart Machine","Dormant Beauty","Nas: Time Is Illmatic","Still Alice","Siddharth","Master of the Universe","The Kill Team","Fed Up","Double Play: James Benning and Richard Linklater","The Raid 2","22 Jump Street","Gebo and the Shadow","Edge of Tomorrow","Hanna Ranch","Copenhagen","Botso","Run & Jump","As It Is in Heaven","Next Goal Wins","Remote Area Medical","Get On Up","Fatal Assistance","Bird People","Maidentrip","Captain America: The Winter Soldier",
"Gabrielle"]

list =["Best Kept Secret", "12 Years a Slave"]

# 2. POST TO FIND MOVIE
list.each do |movie|
  response = Unirest.post "https://byroredux-metacritic.p.mashape.com/find/movie",
    headers:{
      "X-Mashape-Key" => "#{ENV['metacritic_key']}",
      "Content-Type" => "application/x-www-form-urlencoded",
      "Accept" => "application/json"
    },
    parameters:{
      "retry" => 4,
      "title" => movie
    }
  if response.body["result"] && !Movie.find_by(:name => response.body["result"]["name"])
    new_movie = Movie.create
    new_movie.name = response.body["result"]["name"]
    new_movie.score = response.body["result"]["score"].to_i
    new_movie.release_date = response.body["result"]["rlsdate"]
    new_movie.thumbnail_url = response.body["result"]["thumbnail"]
    new_movie.summary = response.body["result"]["summary"]
    new_movie.runtime = response.body["result"]["runtime"]
    new_movie.metacritic_url = response.body["result"]["url"]
    new_movie.genres = []
    response.body["result"]["genre"].split("\n").each do |genre|
      new_movie.genres << Genre.find_or_create_by(:name => genre)
    end
    new_movie.save
    # build reviews for movie
    movie_response = Unirest.get "https://byroredux-metacritic.p.mashape.com/reviews?url=#{new_movie.to_slug}",
    headers:{
      "X-Mashape-Key" => "#{ENV['metacritic_key']}",
      "Accept" => "application/json"
    }

    if movie_response.code == 200
      movie_response.body["result"].each do |review|
        critic_review = CriticReview.new
        critic_review.movie = new_movie
        critic_review.score = review["score"].to_i     
        critic_review.excerpt = review["excerpt"]
        critic_review.link = review["link"]
        if review["author"] && !new_movie.critics.include?(review["author"])
          critic_review.critic = Critic.find_or_create_by(:name => review["author"]) 
        else
          critic_review.critic = Critic.create
        end

        critic_review.publication = Publication.find_or_create_by(:name => review["critic"])
        critic_review.save

        critic = Critic.find(critic_review.critic.id)
        
        publication = Publication.find(critic_review.publication.id)
        critic.publications << publication if !critic.publications.include?(publication)

        critic.save
      end
    end

    new_movie.save

  end
end



