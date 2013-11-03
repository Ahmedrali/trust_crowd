class Alternative < ActiveRecord::Base
  belongs_to :problem
  validates :name, uniqueness: true
end
