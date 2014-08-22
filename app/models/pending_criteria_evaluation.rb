class PendingCriteriaEvaluation < ActiveRecord::Base
  belongs_to :problem
  belongs_to :criterium
  belongs_to :user
end
