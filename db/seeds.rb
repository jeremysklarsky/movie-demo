# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

# 1. Gather list of movies
# twenty_fourteen_movies_two = ["It Felt Like Love","Housebound","The Dog","The Guest","Vic + Flo Saw a Bear","The Lunchbox","Horses of God","Afternoon of a Faun: Tanaquil Le Clercq","Wild","Listen Up Philip","Obvious Child","How to Train Your Dragon 2","Guardians of the Galaxy","The Dance of Reality","Nightcrawler","Happy Valley","Kids for Cash","Aatsinki: The Story of Arctic Cowboys","Waiting for August","Frank","The Retrieval","The Trip to Italy","Honey","Goodbye to Language 3D","Night Moves","The Kingdom of Dreams and Madness","The Battered Bastards of Baseball","Rich Hill","2 Autumns, 3 Winters","Plot for Peace","The Great Flood","Omar","The Skeleton Twins","Dancing in Jaffa","The Vanquishing of the Witch Baba Yaga","X-Men: Days of Future Past","Unrelated","Finding Vivian Maier","Bad Hair","Interstellar","Big Hero 6","Whitey: United States of America v. James J. Bulger","Joe","Like Father, Like Son","A Field in England","A Most Wanted Man","The Imitation Game","Ai Weiwei: The Fake Case","Cheatin'","Beyond the Lights","Once Upon a Time Verônica","Le Week-End","Mistaken for Strangers","Little Feet","Witching and Bitching","Cold in July","A Picture of You","American Sniper","Diplomacy","True Son","In Bloom","The Blue Room","7 Boxes","Exhibition","The Rocket","A People Uncounted","Gore Vidal: The United States of Amnesia","Violette","When I Saw You","The Great Invisible","Brothers Hypnotic","The Way He Looks","The Theory of Everything","The Internet's Own Boy: The Story of Aaron Swartz","The Heart Machine","Dormant Beauty","Nas: Time Is Illmatic","Still Alice","Siddharth","Master of the Universe","The Kill Team","Fed Up","Double Play: James Benning and Richard Linklater","The Raid 2","22 Jump Street","Gebo and the Shadow","Edge of Tomorrow","Hanna Ranch","Copenhagen","Botso","Run & Jump","As It Is in Heaven","Next Goal Wins","Remote Area Medical","Get On Up","Fatal Assistance","Bird People","Maidentrip","Captain America: The Winter Soldier", "Gabrielle"]

# list =["Best Kept Secret", "12 Years a Slave"]
MOVIES_2013 = ["Zero Dark Thirty", "Amour", "Almayer's Folly", "A Man Vanishes (1967)", "This Is Not a Film", "Nothing But a Man (1964)", "Elena", "The Kid with a Bike", "Gregory Crewdson: Brief Encounters", "Lincoln", "How to Survive a Plague", "Barbara", "Argo", "The Master", "Beasts of the Southern Wild", "Paradise Lost 3: Purgatory", "Holy Motors", "Moonrise Kingdom", "Oslo, August 31st","Looper","The Waiting Room","The Day He Arrives","The Flat","Monsieur Lazhar","The Deep Blue Sea","Ornette: Made in America (1985)","El Velador","In the Family","Burn","Footnote","Marley","Under African Skies","Side by Side","Once Upon a Time in Anatolia","The Trouble with the Truth","Sister","Django Unchained","Skyfall","Tchoupitoulas","Consuming Spirits","A Simple Life","Ai Weiwei: Never Sorry","Silver Linings Playbook","The Secret World of Arrietty","The Queen of Versailles","The Turin Horse","I Wish","Goodbye First Love","West of Memphis","The Sessions","Photographic Memory","The Central Park Five","Wagner's Dream","Life of Pi","Keep the Lights On","Searching for Sugar Man","The Law in These Parts","Oki's Movie","Beware of Mr. Baker","Tatsumi","Tabu","5 Broken Cameras","The Dark Knight Rises","Booker's Place: A Mississippi Story","China Heavyweight","Jiro Dreams of Sushi","Las Acacias","Neighboring Sounds","The Imposter","Gerhard Richter - Painting","The House I Live In","Two Years at Sea","Brooklyn Castle","High Ground","Chico & Rita","The Hunter","Hara-Kiri: Death of a Samurai","Flight","The Miners' Hymns","The Loneliest Planet","Patience (After Sebald)","Easy Money","Sleepless Night","Ballplayer: Pelotero","Bernie","Chasing Ice","The Invisible War","Middle of Nowhere","The Thieves","Marina Abramovic: The Artist Is Present","The Rabbi's Cat","Found Memories","Frankenweenie","The Wise Kids","Polisse","Fake It So Real","Where Are You Taking Me?","Bully","In Darkness", "Neil Young Journeys"]

# 2. POST TO FIND MOVIE
MOVIES_2013.each do |movie|
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



