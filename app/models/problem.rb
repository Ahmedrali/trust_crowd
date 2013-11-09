class Problem < ActiveRecord::Base
  
  has_many  :users_problems
  has_many  :users, :through => :users_problems
  has_many  :alternatives
  has_many  :criteria
  
  validates :name, uniqueness: true
  validates :name, :desc, presence: true
  
  PENDING = "pending"
  ACTIVE  = "active"
  CLOSED  = "closed"
  STATUS  = [PENDING, ACTIVE, CLOSED]
  
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
  
end
