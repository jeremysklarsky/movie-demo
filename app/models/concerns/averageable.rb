module Averageable

  module ClassMethods
    def avg_score_list
      my_class = self.to_s.downcase
      sql = 
      "SELECT #{my_class}s.name, COUNT(*) as review_count, AVG(score) as average 
      FROM #{my_class}s 
      JOIN critic_reviews ON #{my_class}s.id = critic_reviews.#{my_class}_id 
      GROUP BY #{my_class}s.name 
      HAVING COUNT(*) > 8 
      ORDER BY average DESC" 
    
    result = ActiveRecord::Base.connection.execute(sql)

    end
  end

  module InstanceMethods
    def user_avg
      if self.user_reviews.size > 0
        self.user_reviews.collect{|review| review.score}.inject(:+) / self.reviews.size.to_f 
      else
        "No users have reviewed this film."
      end
    end

    def avg_score
      (self.reviews.collect{|review| review.score}.inject(:+) / self.reviews.size.to_f).round(1)
    end
  end



end