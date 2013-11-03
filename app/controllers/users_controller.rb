class UsersController < ApplicationController
  def index
    @pending_problems = current_user.problems.where(:status => Problem::PENDING)
    @active_problems = current_user.problems.where(:status => Problem::ACTIVE)
    @closed_problems = current_user.problems.where(:status => Problem::CLOSED)
  end
end