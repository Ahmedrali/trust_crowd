class PendingAlternativesEvaluation < ActiveRecord::Base
  belongs_to :problem
  belongs_to :alternative
  belongs_to :user
end
