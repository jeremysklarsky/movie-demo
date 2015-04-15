require 'rails_helper'

RSpec.describe CriticMatcher, type: :model do
    before(:each) do 
      @user = User.create(:name => "Jeremy Sklarsky",:email => "jeremy.sklarsky@gmail.com")

      @big_lebowski = Movie.create(:name => "The Big Lebowski", :score => 81)
      @boyhood = Movie.create(:name => "Boyhood",:score => 92) 
      @captain_america = Movie.create(:name => "Captain America", :score => 74)
      @x_men = Movie.create(:name => "X-Men", :score => 78) 
      @rochelle = Movie.create(:name => "Rochelle, Rochelle", :score => 81)
      @user_review1 = UserReview.create(user_id: @user.id, movie_id: @big_lebowski.id, score: 69)
      @user_review2 = UserReview.create(user_id: @user.id, movie_id: @boyhood.id, score: 95)
      @user_review3 = UserReview.create(user_id: @user.id, movie_id: @captain_america.id, score: 78 )
      @user_review4 = UserReview.create(user_id: @user.id, movie_id: @x_men.id, score: 75)


      @ao_scott = Critic.create(:name => "AO Scott")
      @roger_ebert = Critic.create(:name => "Roger Ebert")
      @leonard_maltin = Critic.create(:name => "Leonard Maltin")
      @owen = Critic.create(:name => "Owen Gleiberman")
      @andy = Critic.create(:name => "Andy Greenwald")

      @ew = Publication.create(:name => "EW")
      @nytimes = Publication.create(:name => "NY Times")

      CriticReview.create(:critic_id => @big_lebowski.id, :publication_id => @nytimes.id, :score => 90);
      CriticReview.create(:critic_id => @peter_travers.id, :movie_id => @boyhood.id, :publication_id => @nytimes.id, :score => 75)
      CriticReview.create(:critic_id => @peter_travers.id, :movie_id => @captain_america.id, :publication_id => @nytimes.id, :score => 100)
      CriticReview.create(:critic_id => @peter_travers.id, :movie_id => @x_men.id, :publication_id => @nytimes.id, :score => 60)
      CriticReview.create(:critic_id => @ao_scott.id, :movie_id => @big_lebowski.id, :publication_id => @nytimes.id, :score => 73)
      CriticReview.create(:critic_id => @ao_scott.id, :movie_id => @boyhood.id, :publication_id => @nytimes.id, :score => 100)
      CriticReview.create(:critic_id => @ao_scott.id, :movie_id => @captain_america.id, :publication_id => @nytimes.id, :score => 70)
      CriticReview.create(:critic_id => @roger_ebert.id, :movie_id => @captain_america.id, :publication_id => @ew.id, :score => 80)
      CriticReview.create(:critic_id => @leonard_maltin.id, :movie_id => @captain_america.id, :publication_id => @nytimes.id, :score => 50)
      CriticReview.create(:critic_id => @leonard_maltin.id, :movie_id => @x_men.id, :publication_id => @nytimes.id, :score => 100)
      CriticReview.create(:critic_id => @owen.id, :movie_id => @big_lebowski.id, :publication_id => @ew.id, :score => 80)
      CriticReview.create(:critic_id => @owen.id, :movie_id => @boyhood.id, :publication_id => @ew.id, :score => 100)
      CriticReview.create(:critic_id => @owen.id, :movie_id => @captain_america.id, :publication_id => @ew.id, :score => 70)
      CriticReview.create(:critic_id => @owen.id, :movie_id => @x_men.id, :publication_id => @ew.id, :score => 75)
      CriticReview.create(:critic_id => @peter_travers.id, :movie_id => @rochelle.id, :publication_id => @nytimes.id, :score => 80)
      CriticReview.create(:critic_id => @ao_scott.id, :movie_id => @rochelle.id, :publication_id => @nytimes.id, :score => 60)
      CriticReview.create(:critic_id => @roger_ebert.id, :movie_id => @rochelle.id, :publication_id => @ew.id, :score => 100)
      CriticReview.create(:critic_id => @leonard_maltin.id, :movie_id => @rochelle.id, :publication_id => @nytimes.id, :score => 75)
      CriticReview.create(:critic_id => @owen.id, :movie_id => @rochelle.id, :publication_id => @ew.id, :score => 90)
      CriticReview.create(:critic_id => @andy.id, :movie_id => @rochelle.id, :publication_id => @ew.id, :score => 50)
    # end
    @user.save

  end

  describe 'model basics' do
    it "knows about the user's reviews" do

      binding.pry
      expect(@user.reviews.size).to eq(4)
    end

    it "knows a movie's score" do
      expect(@big_lebowski.score).to eq(81)
    end

    it "knows about the user's scores" do
      expect(@user.reviews.find_by(:movie_id => @big_lebowski.id).score).to eq(69)  
    end

    it "knows a critic's average score" do
      expect(@ao_scott.avg_score).to eq(75.8)
    end
  end

  describe 'critic matching' do
    it "knows what critics haven't reviewed similar movies as user" do
      cm = CriticMatcher.new(@user)
      expect(cm.find_user_critics).not_to include(@andy)
    end

    it "knows what critics have reviewed similar movies as user" do
      cm = CriticMatcher.new(@user)
      expect(cm.find_user_critics).to include(@ao_scott)
      expect(cm.find_user_critics.size).to eq(5)
    end

    it "knows a user's similarity score with a critic" do
      expect(@user.similarity_score(@ao_scott)).to eq(94.33)
      expect(@user.similarity_score(@peter_travers)).to eq(80.50)
      expect(@user.similarity_score(@roger_ebert)).to eq(98.00)
      expect(@user.similarity_score(@leonard_maltin)).to eq(73.50)
      expect(@user.similarity_score(@owen)).to eq(94.00)
    end

    it "knows a user's top critic" do
      expect(@user.top_critic).to eq(@ao_scott)
    end

  end

  describe 'adjusted scores' do

    it "knows the overlap factor for a user and critic" do
      expect(@user.critic_overlap(@ao_scott)).to eq(0.75)
      expect(@user.critic_overlap(@peter_travers)).to eq(1)
      expect(@user.critic_overlap(@andy)).to eq(0)
    end

    it "knows weighted overlap factor for a user and critic" do
      expect(@user.critic_overlap_weighted(@ao_scott)).to eq(0.88)
      expect(@user.critic_overlap_weighted(@peter_travers)).to eq(1)
    end

    it "generates the for the user an adjusted score for a movie" do
      expect(@user.adjusted_score(@rochelle)).to eq(69.5)
    end

  end


end



