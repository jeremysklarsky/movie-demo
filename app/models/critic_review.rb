class CriticReview < ActiveRecord::Base
  belongs_to :critic
  belongs_to :movie
  belongs_to :publication
end
