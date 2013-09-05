class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :omniauthable
  
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
end
