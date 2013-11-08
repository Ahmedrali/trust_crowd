class CriteriaController < ApplicationController
  before_action :set_criterium, only: [:show, :edit, :update, :destroy, :active]
  before_action :set_problem
  
  # GET /problems/:problem_id/criteria
  def index
    @criteria = @problem.criteria.where(:reject => false).paginate(:page => params[:page])
    render layout: false
  end

  # GET /problems/:problem_id/criteria
  def rejected
    @criteria = @problem.criteria.where(:reject => true).paginate(:page => params[:page])
    render layout: false
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
      params.require(:criterium).permit(:name, :desc, :tw_hash, :problem_id, :alternatives_matrix, :alternatives_value, :weight)
    end
end
