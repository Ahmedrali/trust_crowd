class Criterium < ActiveRecord::Base
  
  has_many :subcriteria, class_name: "Criterium", foreign_key: "parent_id"
 
  belongs_to :parent, class_name: "Criterium"
  
  belongs_to :problem
  has_many :evaluations
  
  validates :name, uniqueness: true
  validates :name, :desc, presence: true
  
  scope :active, where(:reject => false)
  scope :firstLevel, where(:reject => false, :parent_id => -1)
  
  def isParent?
    parent = false
    Criterium.where(:parent_id => self.id).each do |c|
      parent = (!c.reject or parent)
    end
    parent
  end
  
  def hasSubcriteria?
    self.subcriteria.where(:reject => false).count > 0
  end
  
  def hasSubcriteriaToEvaluate?
    self.subcriteria.where(:reject => false).count > 1
  end
  
end
