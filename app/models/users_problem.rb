class UsersProblem < ActiveRecord::Base
  belongs_to :user
  belongs_to :problem
end