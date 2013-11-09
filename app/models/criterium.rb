class Criterium < ActiveRecord::Base
  belongs_to :problem
  
  validates :name, uniqueness: true
  validates :name, :desc, presence: true
end
