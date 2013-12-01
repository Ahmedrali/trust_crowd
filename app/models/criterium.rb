class Criterium < ActiveRecord::Base
  
  belongs_to :problem
  has_many :evaluations
  
  validates :name, uniqueness: true
  validates :name, :desc, presence: true
end
