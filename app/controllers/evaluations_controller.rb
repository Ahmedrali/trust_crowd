class EvaluationsController < ApplicationController
  before_action :set_problem
  before_action :set_criterium
  before_action :set_evaluation

  def get
    @hasSubcriteria = @criterium.hasSubcriteria?
    unless @evaluation and @evaluation.alternatives_value.count == @problem.alternatives.where(:reject => false).count
      evaluation = init_problem_criteria_evaluation
      mat = getMatrix(@problem.alternatives.where(:reject => false).count, evaluation)
      weights = checkConsistency(mat)
      if weights.class == Array
        @evaluation = Evaluation.new unless @evaluation 
        @evaluation.criteria_id = @criterium.id
        @evaluation.user_id = current_user.id
        @evaluation.alternatives_value = mapIDValue(@problem.alternatives.where(:reject => false), weights)
        @evaluation.alternatives_matrix = evaluation
        @evaluation.save
      end
    end
    @alternatives         = @problem.alternatives.where(:reject => false)
    @alternatives_weight  = @evaluation.alternatives_value
    @alternatives_matrix  = @evaluation.alternatives_matrix
  end

  def save
    mat = params['matrix']
    old_mat = @evaluation.alternatives_matrix
    mat.each_pair do |key, val|
      s, src, trg, v = key.split("-")
      puts key, old_mat[src][trg], val.to_f
      old_mat[src][trg] = val.to_f
    end
    mat = getMatrix(@problem.alternatives.where(:reject => false).count, old_mat)
    weights = checkConsistency(mat)
    if weights.class == Array
      @evaluation.update!(:alternatives_matrix => old_mat, :alternatives_value => mapIDValue(@problem.alternatives.where(:reject => false), weights))
      render text: I18n.t(:success_save_evaluation), layout: false
    elsif weights == false
      render text: I18n.t(:reevaluate), layout: false
    end
  end

  private
  
    def set_problem
      @problem = Problem.find(params[:problem_id])
    end
    
    def set_criterium
      @criterium = Criterium.find(params[:criterium_id])
    end
    
    def set_evaluation
      @evaluation = Evaluation.where(:criteria_id => @criterium.id, :user_id => current_user.id).first
    end
    
    def init_problem_criteria_evaluation
      alternatives = @problem.alternatives.where(:reject => false)
      evaluation = {}
      alternatives.each do |src|
        unless evaluation.include?(src.name) or alternatives.last == src
          evaluation[src.name] = {}
        end
        alternatives.each do |trg|
          if trg.id > src.id
            evaluation[src.name].merge!({trg.name => 1})
          end
        end
      end
      evaluation
    end
end
