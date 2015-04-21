class CriticReview < ActiveRecord::Base
  belongs_to :critic
  belongs_to :movie
  belongs_to :publication

  def truncated_excerpt
    if self.excerpt.size >= 110
      "#{self.excerpt[0..107]}..."
    else
      self.excerpt
    end
  end
end
