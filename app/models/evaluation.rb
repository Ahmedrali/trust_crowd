class Evaluation < ActiveRecord::Base
  serialize :alternatives_matrix
  serialize :alternatives_value
  
  belongs_to :user
  belongs_to :criterium
end
