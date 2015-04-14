class CriticPublication < ActiveRecord::Base
  belongs_to :critic
  belongs_to :publication
end
