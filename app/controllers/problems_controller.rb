class ProblemsController < ApplicationController
  before_action :set_problem, only: [:show, :edit, :update, :destroy, :active, :close, :participate, :evaluate, :finish_evaluation, :ranking]
  # GET /problems
  # GET /problems.json
  def index
    problem_status = params["status"]
    @problems = []
    if Problem::STATUS.include?(problem_status)
      @problems = current_user.problems.where(:status => problem_status)
      @status = problem_status
    end
    respond_to do |format|
      format.js
    end
  end
  
  def search
    @q = params[:q] || ""
    search_for = "%#{@q}%"
    @problems = Problem.where("name like ? or desc like ? or tw_hash like ? ", search_for, search_for, search_for).paginate(:page => params[:page])
  end
  
  # GET /problems/1
  # GET /problems/1.json
  def show
    render layout: false
  end

  # GET /problems/new
  def new
    @problem = Problem.new
    render layout: false
  end

  # GET /problems/1/edit
  def edit
    render layout: false
  end

  # POST /problems
  # POST /problems.json
  def create
    @problem = Problem.new(problem_params)
    @problem.tw_hash  = "tc_p#{Problem.count}"
    @problem.status   = Problem::PENDING
    if @problem.save
      UsersProblem.create(:user => current_user, :problem => @problem, :owner => true)
      render text: @problem.id, layout: false
    else
      render template: "problems/new.html.erb", layout: false
    end
  end

  # PATCH/PUT /problems/1
  # PATCH/PUT /problems/1.json
  def update
    if @problem.update(problem_params)
      render text: @problem.id, layout: false
    else
      render template: "problems/edit.html.erb", layout: false
    end
  end

  # DELETE /problems/1
  # DELETE /problems/1.json
  def destroy
    redirect_to root_path
  end

  # GET /problems/1/active
  def active
    Problem.transaction do
      if @problem.activate
        if @problem.criteria.first.weight.nil? or @problem.criteria.first.weight.empty?
          @problem.criteria.update_all(:weight => (1/Float(@problem.criteria.count)))
        end
        render text: @problem.id, layout: false
      end
    end
  end
  
  # GET /problems/1/active
  def close
    if @problem.close
      render text: @problem.id, layout: false
    end
  end

  # GET /problems/1/participate
  def participate
    if @problem and !@problem.users.exists?(current_user)
      UsersProblem.create(:user => current_user, :problem => @problem, :owner => false)
      redirect_to root_path, :notice => "Successfully participated."
    end
  end
  
  def ranking
    criteria = @problem.criteria
    criteria_weights      = Matrix.rows([ criteria.map{|c| c.weight.to_f} ]).transpose
    criteria_evaluations  = Matrix.rows( criteria.map{|c| JSON.parse(c.alternatives_value)} ).transpose
    @alternative_weights  = criteria_evaluations * criteria_weights
    @alternatives         = @problem.alternatives
  end
  
  def evaluate
    @criteria = @problem.criteria
    render layout: false
  end
  
  def finish_evaluation
    render text: @problem.id, layout: false
  end
  
  private
    # Use callbacks to share common setup or constraints between actions.
    def set_problem
      @problem = Problem.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def problem_params
      params.require(:problem).permit(:name, :desc)
    end
    
end
