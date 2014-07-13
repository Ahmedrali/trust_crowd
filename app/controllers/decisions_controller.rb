class DecisionsController < ApplicationController
  
  def getIndividual
    prob = Problem.find(params["prob"])
    @user_decision = {}
    decision = calcFinalDecision(prob, current_user)
    decision.each_pair{ |k,v| @user_decision[Alternative.find(k).name] = v }
    respond_to do |format|
      format.json  { render :json => @user_decision.to_json }
    end
  end
  
  private
  def calcFinalDecision(problem, user)
    alternatives  = problem.alternatives.where(:reject => false).count
    criteria = problem.criteria.select(&:active?).reject(&:isParent?)
    final_evals = {}
    problem.criteria.select(&:active?).select(&:firstLevel?).map{|c| final_evals[c.id] = {}}
    criteria.each do |criterium|
      eval = Evaluation.where(:criteria_id => criterium.id, :user_id => user.id).first.alternatives_value rescue nil
      if eval
        curr_criteria = criterium.id
        parent = criterium.parent_id
        while parent > -1
          if (criteria_evluation = CriteriaEvaluation.where(:user_id => user.id, :criterium_id => parent, :problem_id => problem.id).first)
            criteria_wieght = criteria_evluation.criteria_value[curr_criteria]
          else
            criteria_wieght = 1/Float(problem.subcriteriaOf(parent).count)
          end
          eval.map{|k, v| eval[k] = v * criteria_wieght}
          curr_criteria = parent
          parent = Criterium.find(parent).parent_id
        end
        # handle the parent of -1
        if (criteria_evluation = CriteriaEvaluation.where(:user_id => user.id, :criterium_id => parent, :problem_id => problem.id).first)
          criteria_wieght = criteria_evluation.criteria_value[curr_criteria]
        else
          criteria_wieght = 1/Float(problem.subcriteriaOf(parent).count)
        end
        eval.map{|k, v| eval[k] = v * criteria_wieght}
        if not final_evals[curr_criteria].empty?
          eval.each do |k, v|
            final_evals[curr_criteria][k] += eval[k]
          end
        else
          final_evals[curr_criteria] = eval
        end
      end
    end
    alternatives_values = {}
    problem.alternatives.where(:reject => false).each{|alt| alternatives_values[alt.id] = 0}
    final_evals.map do |k, v| 
      v.map{ |alt_id, alt_val| alternatives_values[alt_id] += alt_val }
    end
    alternatives_values
  end
end