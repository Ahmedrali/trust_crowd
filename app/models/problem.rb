class Problem < ActiveRecord::Base
  has_many  :users_problems
  has_many  :users, :through => :users_problems
  has_many  :alternatives
  has_many  :criteria
  
  PENDING = "pending"
  ACTIVE  = "active"
  CLOSED  = "closed"
  
end
