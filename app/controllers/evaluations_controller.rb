class EvaluationsController < ApplicationController
  before_action :set_problem
  before_action :set_criterium
  before_action :set_evaluation

  def get
    @hasSubcriteria = @criterium.hasSubcriteria?
    unless @evaluation and JSON.parse(@evaluation.alternatives_value).count == @problem.alternatives.count
      evaluation = init_problem_criteria_evaluation
      mat = getMatrix(@problem.alternatives.count, evaluation)
      weights = checkConsistency(mat)
      if weights.class == Array
        @evaluation = Evaluation.new unless @evaluation 
        @evaluation.criteria_id = @criterium.id
        @evaluation.user_id = current_user.id
        @evaluation.alternatives_value = weights.to_json
        @evaluation.alternatives_matrix = evaluation.to_json
        @evaluation.save
      end
    end
    @alternatives         = @problem.alternatives
    @alternatives_weight  = JSON.parse(@evaluation.alternatives_value)
    @alternatives_matrix  = JSON.parse(@evaluation.alternatives_matrix)
  end

  def save
    mat = params['matrix']
    old_mat = JSON.parse(@evaluation.alternatives_matrix)
    puts old_mat
    mat.each_pair do |key, val|
      s, src, trg, v = key.split("-")
      puts key, old_mat[src][trg], val.to_f
      old_mat[src][trg] = val.to_f
    end
    puts old_mat
    mat = getMatrix(@problem.alternatives.count, old_mat)
    weights = checkConsistency(mat)
    if weights.class == Array
      puts old_mat, weights
      @evaluation.update!(:alternatives_matrix => old_mat.to_json, :alternatives_value => weights.to_s)
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
      alternatives = @problem.alternatives
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
