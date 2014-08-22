class CriteriaController < ApplicationController
  before_action :set_criterium, only: [:show, :edit, :update, :destroy, :active, :ranking, :save_evaluation, :vote, :finish_voting]
  before_action :set_problem
  
  # GET /problems/:problem_id/criteria
  def index
    @criteria = @problem.criteria.where(:pending => false, :reject => false).paginate(:page => params[:page])
    render layout: false
  end

  # GET /problems/:problem_id/criteria/pending
  def pending
    @criteria = @problem.criteria.where(:pending => true).paginate(:page => params[:page])
    render layout: false
  end

  # GET /problems/:problem_id/criteria/rejected
  def rejected
    @criteria = @problem.criteria.where(:pending => false, :reject => true).paginate(:page => params[:page])
    render layout: false
  end
  
  # POST /problems/:problem_id/criteria/:id/vote/:decision
  def vote
    decision = params[:decision] == "true"
    if @criterium.pendingCriteriaEvaluations.exists?(:user_id => current_user.id)
      @criterium.pendingCriteriaEvaluations.find_by(:user_id => current_user.id).update(:decision => decision)
      msg = "updated"
    else
      PendingCriteriaEvaluation.create(:problem_id => @problem.id, :criterium_id => @criterium.id, :user_id => current_user.id, :decision => decision)
      msg = "created"
    end
    render text: msg, layout: false
  end
  
  # GET /problems/:problem_id/criteria/:id/finish_voting
  def finish_voting
    @criterium.pending = false
    if @criterium.acceptance_votes > @criterium.refused_votes
      @criterium.reject = false
      msg = "accepted"
    else
      @criterium.reject = true
      msg = "refused"
    end
    @criterium.save
    render text: msg, layout: false
  end
  
  # GET /problems/:problem_id/criteria/1
  def show
    render layout: false
  end

  # GET /problems/:problem_id/criteria/new
  def new
    @criterium = @problem.criteria.new
    render layout: false
  end

  # GET /problems/:problem_id/criteria/1/edit
  def edit
    render layout: false
  end

  # POST /problems/:problem_id/criteria
  def create
    @criterium = @problem.criteria.new(criterium_params)
    @criterium.tw_hash  = "#{@problem.tw_hash}_c#{@problem.criteria.count}"
    @criterium.pending = true
    @criterium.reject = true
    if @criterium.save
      render text: @criterium.id, layout: false
    else
      render template: "criteria/new.html.erb", layout: false
    end
  end

  # PATCH/PUT /problems/:problem_id/criteria/1
  def update
    if @criterium.update(criterium_params)
      render text: @criterium.id, layout: false
    else
      render template: "criteria/edit.html.erb", layout: false
    end
  end

  # DELETE /problems/:problem_id/criteria/1
  def destroy
    @criterium.reject = true
    @criterium.save
    render text: "ok", layout: false
  end

  # GET /problems/:problem_id/criteria/1
  def active
    @criterium.reject = false
    @criterium.save
    render text: "ok", layout: false
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_criterium
      @criterium = Criterium.find(params[:id])
    end
    
    # Use callbacks to share common setup or constraints between actions.
    def set_problem
      @problem = Problem.find(params[:problem_id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def criterium_params
      params.require(:criterium).permit(:name, :desc, :problem_id, :weight, :parent_id)
    end
end
