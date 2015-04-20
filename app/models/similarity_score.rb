class SimilarityScore < ActiveRecord::Base
  belongs_to :user
  belongs_to :critic

end