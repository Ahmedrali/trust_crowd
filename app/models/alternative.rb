class Alternative < ActiveRecord::Base
  belongs_to :problem
  has_many :pendingAlternativesEvaluations
  
  validates :name, uniqueness: true
  validates :name, :desc, presence: true
  
  scope :active, where(:reject => false)
  
  def acceptance_votes
    self.pendingAlternativesEvaluations.where(:decision => true).count
  end
  
  def refused_votes
    self.pendingAlternativesEvaluations.where(:decision => false).count
  end
  
end
