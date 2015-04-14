class Publication < ActiveRecord::Base

    extend Averageable::ClassMethods
    include Averageable::InstanceMethods

  has_many :critic_publications
  has_many :critics, :through => :critic_publications
  
  has_many :critic_reviews

  def reviews
    self.critic_reviews
  end

  def critics
    self.critic_reviews.collect{|review|review.critic}.uniq
  end


  
end
