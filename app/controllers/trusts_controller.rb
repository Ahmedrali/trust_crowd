class TrustsController < ApplicationController
  before_action :set_problem
  
  def index
    # Users who I trusted in
    ids = current_user.trusts.map{|t| t.to} || []
    @trusted_users = User.where(:id => ids).paginate(:page => params[:page])
    
    ids.concat(Trust.where(:to => current_user.id).map{|t| t.user_id})
    @users = @problem.users.where('user_id not in (?)', ids.push(current_user.id)).paginate(:page => params[:page])
    
    # Users who trusted in Me
    @trustee_users = current_user.trustee(@problem).paginate(:page => params[:page])
    
    @delegated = current_user.delegated_user(@problem)
    @delegated_user = User.find(current_user.trusts.where(:delegate => true).first.to) if @delegated
  end
  
  def delegate
    to = params["user_id"]
    unless delegated_user = current_user.delegated_user(@problem)
      Trust.where(:problem_id => @problem.id, :user_id => current_user.id, :to => to).first.update(:delegate => true)
      delegated_user = User.find(current_user.trusts.where(:delegate => true).first.to).twitter_nickname
      redirect_to problem_trusts_path, :error => "You are delegated your choice to '#{delegated_user}' successfully."
    else
      delegated_user = User.find(current_user.trusts.where(:delegate => true).first.to).twitter_nickname
      redirect_to problem_trusts_path, :error => "You already delegated your choice to '#{delegated_user}'"
    end
  end
  
  def undelegate
    to = params["user_id"]
    if delegated_user = current_user.delegated_user(@problem)
      delegated_user = User.find(current_user.trusts.where(:delegate => true).first.to).twitter_nickname
      Trust.where(:problem_id => @problem.id, :user_id => current_user.id, :to => to).first.update(:delegate => false)
      redirect_to problem_trusts_path, :error => "You revoked you delegation from '#{delegated_user}' successfully."
    else
      redirect_to problem_trusts_path, :error => "You are not delegated your choice to any participant."
    end
  end
  
  def trust
    to = params["user_id"]
    trust = Trust.new(:problem_id => @problem.id, :user_id => current_user.id, :to => to)
    if trust.save
      redirect_to problem_trusts_path, :notice => "Your trust relation to #{User.find(to).twitter_nickname} is successfully created."
    else
      redirect_to problem_trusts_path, :error => "Sorry, There is a problem."
    end
  end
  
  def untrust
    to = params["user_id"]
    trust = Trust.where(:problem_id => @problem.id, :user_id => current_user.id, :to => to)
    if trust.delete_all
      redirect_to problem_trusts_path, :notice => "Your trust relation to #{User.find(to).twitter_nickname} is deleted."
    else
      redirect_to problem_trusts_path, :error => "Sorry, There is a problem."
    end
  end
  
  private
  def set_problem
    @problem = Problem.find(params[:problem_id])
  end
end