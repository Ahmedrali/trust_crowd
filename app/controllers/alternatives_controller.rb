class AlternativesController < ApplicationController
  before_action :set_alternative, only: [:show, :edit, :update, :destroy, :active, :vote, :finish_voting]
  before_action :set_problem
  
  # GET /problems/:problem_id/alternatives
  def index
    @alternatives = @problem.alternatives.where(:pending => false, :reject => false).paginate(:page => params[:page])
    render layout: false
  end

  # GET /problems/:problem_id/alternatives/pending
  def pending
    @alternatives = @problem.alternatives.where(:pending => true).paginate(:page => params[:page])
    render layout: false
  end

  # GET /problems/:problem_id/alternatives
  def rejected
    @alternatives = @problem.alternatives.where(:pending => false, :reject => true).paginate(:page => params[:page])
    render layout: false
  end
  
  # POST /problems/:problem_id/alternatives/:id/vote/:decision
  def vote
    decision = params[:decision] == "true"
    if @alternative.pendingAlternativesEvaluations.exists?(:user_id => current_user.id)
      @alternative.pendingAlternativesEvaluations.find_by(:user_id => current_user.id).update(:decision => decision)
      msg = "updated"
    else
      PendingAlternativesEvaluation.create(:problem_id => @problem.id, :alternative_id => @alternative.id, :user_id => current_user.id, :decision => decision)
      msg = "created"
    end
    render text: msg, layout: false
  end
  
  # GET /problems/:problem_id/alternatives/:id/finish_voting
  def finish_voting
    @alternative.pending = false
    if @alternative.acceptance_votes > @alternative.refused_votes
      @alternative.reject = false
      msg = "accepted"
    else
      @alternative.reject = true
      msg = "refused"
    end
    @alternative.save
    render text: msg, layout: false
  end

  # GET /problems/:problem_id/alternatives/1
  def show
    render layout: false
  end

  # GET /problems/:problem_id/alternatives/new
  def new
    @alternative = @problem.alternatives.new
    render layout: false
  end

  # GET /problems/:problem_id/alternatives/1/edit
  def edit
    render layout: false
  end

  # POST /problems/:problem_id/alternatives
  def create
    @alternative = @problem.alternatives.new(alternative_params)
    @alternative.tw_hash  = "#{@problem.tw_hash}_a#{@problem.alternatives.count}"
    if @problem.active?
      @alternative.pending = true
      @alternative.reject  = true
    else
      @alternative.pending = false
      @alternative.reject  = false
    end
    if @alternative.save
      render text: @alternative.id, layout: false
    else
      render template: "alternatives/new.html.erb", layout: false
    end
  end

  # PATCH/PUT /problems/:problem_id/alternatives/1
  def update
    if @alternative.update(alternative_params)
      render text: @alternative.id, layout: false
    else
      render template: "alternatives/edit.html.erb", layout: false
    end
  end

  # DELETE /problems/:problem_id/alternatives/1
  def destroy
    @alternative.reject = true
    @alternative.save
    render text: "ok", layout: false
  end

  # GET /problems/:problem_id/alternatives/1
  def active
    @alternative.reject = false
    @alternative.save
    render text: "ok", layout: false
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_alternative
      @alternative = Alternative.find(params[:id])
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_problem
      @problem = Problem.find(params[:problem_id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def alternative_params
      params.require(:alternative).permit(:name, :desc, :problem_id)
    end
end
