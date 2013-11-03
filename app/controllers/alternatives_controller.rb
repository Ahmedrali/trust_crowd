class AlternativesController < ApplicationController
  before_action :set_alternative, only: [:show, :edit, :update, :destroy, :active]
  before_action :set_problem
  
  # GET /problems/:problem_id/alternatives
  def index
    @alternatives = @problem.alternatives.where(:reject => false).paginate(:page => params[:page])
    render layout: false
  end

  # GET /problems/:problem_id/alternatives
  def rejected
    @alternatives = @problem.alternatives.where(:reject => true).paginate(:page => params[:page])
    render layout: false
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
      params.require(:alternative).permit(:name, :desc, :tw_hash, :problem_id)
    end
end
