class CriteriaEvaluationsController < ApplicationController
  before_action :set_problem
  before_action :set_criterium
  before_action :set_evaluation

  def get
    unless @evaluation and JSON.parse(@evaluation.criteria_value).count == @problem.subcriteriaOf(@parent_criterium).count
      evaluation = init_sub_criteria_evaluation
      mat = getMatrix(@problem.subcriteriaOf(@parent_criterium).count, evaluation)
      weights = checkConsistency(mat)
      if weights.class == Array
        @evaluation = CriteriaEvaluation.new unless @evaluation
        @evaluation.problem_id = @problem.id
        @evaluation.criterium_id = @parent_criterium
        @evaluation.user_id = current_user.id
        @evaluation.criteria_value = weights.to_json
        @evaluation.criteria_matrix = evaluation.to_json
        @evaluation.save
      end
    end
    @criteria = @problem.subcriteriaOf(@parent_criterium)
    @weight   = JSON.parse(@evaluation.criteria_value)
    @matrix   = JSON.parse(@evaluation.criteria_matrix)
  end

  def save
    mat = params['matrix']
    old_mat = JSON.parse(@evaluation.criteria_matrix)
    mat.each_pair do |key, val|
      s, src, trg, v = key.split("-")
      puts "*_*_*",key, old_mat[src][trg], val.to_f
      old_mat[src][trg] = val.to_f
    end
    mat = getMatrix(@problem.subcriteriaOf(@parent_criterium).count, old_mat)
    weights = checkConsistency(mat)
    puts "()()()()", weights.to_s, old_mat.to_json
    if weights.class == Array
      @evaluation.update!(:criteria_matrix => old_mat.to_json, :criteria_value => weights.to_s)
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
      @parent_criterium = params[:criterium_id]
    end
    
    def set_evaluation
      @evaluation = CriteriaEvaluation.where(:problem_id => @problem.id, :criterium_id => @parent_criterium, :user_id => current_user.id).first
    end
    
    def init_sub_criteria_evaluation
      subcriteria = @problem.subcriteriaOf(@parent_criterium)
      evaluation = {}
      subcriteria.each do |src|
        src_name = src.name.gsub(" ", "_")
        unless evaluation.include?( src_name ) or subcriteria.last == src
          evaluation[ src_name ] = {}
        end
        subcriteria.each do |trg|
          if trg.id > src.id
            trg_name = trg.name.gsub(" ", "_")
            evaluation[ src_name ].merge!( { trg_name => 1 } )
          end
        end
      end
      evaluation
    end
end
