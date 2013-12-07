class CriteriaEvaluation < ActiveRecord::Base
  
  serialize :criteria_matrix
  serialize :criteria_value
  
  belongs_to :problem
  belongs_to :criterium
  belongs_to :user
end
