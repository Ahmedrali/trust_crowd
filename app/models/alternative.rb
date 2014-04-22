class Alternative < ActiveRecord::Base
  belongs_to :problem
  
  validates :name, uniqueness: true
  validates :name, :desc, presence: true
  
  scope :active, where(:reject => false)
  
end
