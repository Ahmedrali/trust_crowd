class Criterium < ActiveRecord::Base
  
  has_many :subcriteria, class_name: "Criterium", foreign_key: "parent_id"
 
  belongs_to :parent, class_name: "Criterium"
  
  belongs_to :problem
  has_many :evaluations
  
  validates :name, uniqueness: true
  validates :name, :desc, presence: true
  
  scope :parentsCriteria, where(:parent_id => -1)
  scope :active, where(:reject => false)
  
  def isParent?
    self.parent_id == -1
  end
  
  def hasSubcriteria?
    self.subcriteria.where(:reject => false).count > 0
  end
  
  def hasSubcriteriaToEvaluate?
    self.subcriteria.where(:reject => false).count > 1
  end
  
end
