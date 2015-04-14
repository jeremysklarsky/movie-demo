desc "Create dummy user"
task :user_faker => :environment do

  10.times do 
    user = User.create(:name => Faker::Name.name)

    movies = ["Boyhood","Dawn of the Planet of the Apes","The Grand Budapest Hotel","12 Years a Slave","The Theory of Everything","Guardians of the Galaxy","Interstellar","Captain America: The Winter Soldier","X-Men: Days of Future Past","Top Five","Listen Up Philip","The Lunchbox","The Big Lebowski"]

    movies.each do |movie_name|
      @movie = Movie.find_by(:name => movie_name)
      score = rand(50)+51
      UserReview.create(:movie_id => @movie.id, :user_id => user.id, :score => score)

    end
  end
end