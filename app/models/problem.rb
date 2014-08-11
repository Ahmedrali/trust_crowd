class Problem < ActiveRecord::Base
  
  serialize :criteria_matrix
  
  has_many  :users_problems
  has_many  :users, :through => :users_problems
  has_many  :alternatives
  has_many  :criteria
  has_many  :tweets
  has_many  :trusts
  
  validates :name, uniqueness: true
  validates :name, :desc, presence: true
  
  PENDING = "pending"
  ACTIVE  = "active"
  CLOSED  = "closed"
  STATUS  = [PENDING, ACTIVE, CLOSED]
  
  scope :active, where(:status => ACTIVE)
  
  def activate
    self.status = ACTIVE
    self.save
  end
  
  def close
    self.status = CLOSED
    self.save
  end
  
  def pending?
    self.status == PENDING
  end
  
  def active?
    self.status == ACTIVE
  end
  
  def subcriteriaOf(parent_id)
    self.criteria.where(:reject => false, :parent_id => parent_id)
  end
  
  def parentCriteria
    self.criteria.select(&:hasSubcriteriaToEvaluate?).map{|c| [c.name, c.id] }
  end
  
  def getParentSubCriteriaForEvaluation
    criteria = {}
    self.criteria.select(&:active?).each do |criterium|
      criteria.include?(criterium.parent_id) ? criteria[criterium.parent_id].append([criterium.name, criterium.id]) : (criteria[criterium.parent_id] = [[criterium.name, criterium.id]])
    end
    puts criteria
    buildTree(criteria)
  end
  
  def getParentSubCriteria
    criteria = {}
    self.criteria.where(:reject => false).each do |criterium|
      criteria.include?(criterium.parent_id) ? criteria[criterium.parent_id].append([criterium.name, criterium.id]) : (criteria[criterium.parent_id] = [[criterium.name, criterium.id]])
    end
    tree = buildTree(criteria);
    [["No. Parent", -1]].concat(tree || [])
  end
  
  def buildTree(src)
    res = src.delete(-1)
    depth = 1
    while src.count > 0
      str = "--"*depth
      tmp = []
      res.each do |c|
        if src.include?(c[1])
          tmp.concat( [c].concat(src[c[1]].map{|s| ["#{str}| #{s[0]}", s[1]] }) )
          src.delete(c[1])
        else
          tmp.append(c)
        end
      end
      res = tmp.clone
      depth += 1
    end
    res
  end
  
end
