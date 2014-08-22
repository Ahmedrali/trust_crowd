class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :omniauthable
  
  has_many  :users_problems
  has_many  :problems, :through => :users_problems
  has_many  :evaluations
  has_many  :trusts
  
  def self.find_for_twitter(auth, signed_in_resource=nil)
    tw_id       = auth["uid"]
    tw_nickname = auth["info"]["nickname"]
    email       = "#{tw_nickname}@twitter.com"
    user        = User.where(:twitter_id => tw_id).first
    unless user
      password  = Devise.friendly_token[0,8]
      user      = User.create(  twitter_id:tw_id,
                                twitter_nickname:tw_nickname,
                                email:email,
                                password:password
                             )
    end
    user
  end
  
  def trustee(problem)
    User.where(:id => Trust.where(:to => self.id, :problem_id => problem.id).map{|t| t.user_id} )
  end
  
  def delegated_user(problem)
    self.trusts.where(:delegate => true, :problem_id => problem.id).first
  end
  
  def own?(problem)
    self.users_problems.find_by(:problem_id => problem.id).owner
  end
end
