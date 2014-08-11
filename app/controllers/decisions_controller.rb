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
  
  def getCollectiveDecision
    problem = Problem.find(params["prob"])
    decision = callCollectiveDecision(problem)
    respond_to do |format|
      format.json  { render :json => decision.to_json }
    end
  end
  
  def user_satisfactory
    problem = Problem.find(params["prob"])
    user = User.find(params["user"])
    index = satisfactory_index(problem, user)
    respond_to do |format|
      format.json  { render :json => index }
    end
  end
  
  def group_satisfactory
    problem = Problem.find(params["prob"])
    index = group_satisfactory_index(problem)
    respond_to do |format|
      format.json  { render :json => index }
    end
  end
  
  private
  
  # => calc public satisfactory index corresponding to eq_3.11
  def group_satisfactory_index(problem)
    index = 1
    problem.users.each do |u|
      index *= satisfactory_index(problem, u)
    end
    index ** (1.to_f / problem.users.count)
  end
  
  # => calc satisfactory index for user corresponding to eq_3.10
  def satisfactory_index(problem, user)
    wl = calcFinalDecision(problem, user)
    n = diff_coef(problem, wl)
    l = rank_coef(problem, wl)
    p = 0
    n.each_pair do |k, v|
      p += v ** l[k]
    end
    p /= n.keys.count
  end
  
  # => calc rank coefficient for user corresponding to eq_3.9
  def rank_coef(problem, wl)
    alts_name_id = {}
    alts_id_name = {}
    problem.alternatives.where(:reject => false).map {|a| alts_name_id[a.name] = a.id; alts_id_name[a.id] = a.name;}
    alternatives  = alts_name_id.values.sort
    dms           = {}
    problem.users.each do |u| 
      dms[u.id] = calcFinalDecision(problem, u)
    end
    l = {}
    rank    = w_rank(alternatives, dms)
    tmp = wl.values.sort.reverse
    wl.each_pair do |k, v|
      l[k] = ( rank[k] - (alternatives.count.to_f / (tmp.index(v)+1)) ).abs
    end
    l
  end
  
  # => calc differentiation coefficient for user corresponding to eq_3.8
  def diff_coef(problem, wl)
    w = callCollectiveDecision(problem)
    alts_id_name = {}
    problem.alternatives.where(:reject => false).map {|a| alts_id_name[a.id] = a.name;}
    norm = 0
    n = {}
    wl.each_pair do |a, v|
      val = (v - w[alts_id_name[a]]).abs ** -1
      n[a] = val
      norm += val
    end
    n.each_pair{|k, v| n[k] = v / norm}
  end
  
  # => Calculate final decision weights for the n alternatives with the consideration of W-diff & W_rank    
  def callCollectiveDecision(problem)
    alts_name_id = {}
    alts_id_name = {}
    problem.alternatives.where(:reject => false).map {|a| alts_name_id[a.name] = a.id; alts_id_name[a.id] = a.name;}
    alternatives  = alts_name_id.values.sort
    dms           = {}
    problem.users.each do |u|
      dms[u.id] = calcFinalDecision(problem, u)
    end
    wDiff = w_diff(alternatives, problem, dms, alts_name_id)
    wRank = w_rank(alternatives, dms)
    collective_decision = {}
    norm = 0
    wRank.each_pair do |a, rw|
      multi = rw * wDiff[a]
      collective_decision[a] = multi
      norm += multi
    end
    res = {}
    collective_decision.each_pair{|k,v| res[alts_id_name[k]] = v / norm}
    res
  end
  
  # => the overall decision weights about the n alternatives
  # => with the consideration of preferential differences
  def w_diff(alternatives, problem, dms, alts_name_id)
    theta = preferential_difference(dms, alternatives)
    criteria = problem.criteria.select(&:isLeaf)
    blij = bL_ij(dms, alts_name_id, criteria, problem)
    bDiff = b_diff(theta, alternatives, blij)
    w = {}
    norm = 0
    alternatives.each do |i|
      multi = 1
      alternatives.each do |j|
        multi *= bDiff[i][j]
      end
      multi **= (1.to_f/alternatives.count)
      norm += multi
      w[i] = multi
    end
    w.each_pair{|k,v| w[k] = v / norm}
  end

  def bL_ij(dms, alts_name_id, criteria, problem)
    blij = {}
    dms.keys.each do |u|
      blij[u] = {'w' => {}, 'a' => {}}
      criteria.each do |c|
        parent = c.parent_id
        weight = 1
        curr_criterium = c.id
        while parent
          tmp = CriteriaEvaluation.where(:user_id => u, :criterium_id => parent, :problem_id => problem.id).first.criteria_value[curr_criterium]
          weight = weight * tmp
          if parent != -1
            curr_criterium = parent
            parent = Criterium.find(parent).parent_id
          else
            parent = nil
          end
        end
        blij[u]['w'][c.id] = weight
        
        alts_eval = Evaluation.where(:user_id => u, :criteria_id => c.id).first.alternatives_matrix
        alts_mat = {}
        alts_eval.each_pair do |src, vals|
          alts_mat[alts_name_id[src]] = {}
          vals.each_pair do |trg, val|
            alts_mat[alts_name_id[src]][alts_name_id[trg]] = val
          end
        end
        blij[u]['a'][c.id] = alts_mat
      end
    end
    blij
  end

  # => Aggregation matrix of pairwise comparison for the p decision makers 
  # => about the n alternatives at level k is thus given
  def b_diff(theta, alternatives, blij)
    diff = {}
    alternatives.each do |i|
      alternatives.each do |j|
        if i == j
          diff.include?(i) ? diff[i][j] = 1 : diff[i] = {j => 1}
          diff.include?(j) ? diff[j][i] = 1 : diff[j] = {i => 1}
        else
          v = b_diff_cell(i, j, theta, blij)
          diff.include?(i) ? diff[i][j] = v : diff[i] = {j => v}
          v = b_diff_cell(j, i, theta, blij)
          diff.include?(j) ? diff[j][i] = v : diff[j] = {i => v}
        end
      end
    end
    diff
  end
  
  def b_diff_cell(i, j, theta, blij)
    theta_sum = 0
    theta.each_pair do |k, v|
      theta_sum += (v.include?(i) && v[i].include?(j) ? v[i][j] : v[j][i])
    end
    multi = 1
    theta.each_pair do |k, v|
      b = 0 
      blij[k]['w'].each_pair do |c, w|
        b += w * (blij[k]['a'][c].include?(i) && blij[k]['a'][c][i].include?(j) ? blij[k]['a'][c][i][j] : 1.to_f/blij[k]['a'][c][j][i] )
      end
      multi *= b ** (v.include?(i) && v[i].include?(j) ? v[i][j] : v[j][i])
    end
    multi ** (1/theta_sum.to_f)
  end

  # => adjusting weights about the n alternatives 
  # => with the consideration of preferential ranks
  def w_rank(alternatives, dms)
    w = {}
    norm = 0;
    count = alternatives.count
    ranks = delta(dms, count)
    alternatives.each do |a|
      sum = 0
      ranks.each_pair do |d, v|
        sum += v[a]
      end
      norm += sum
      w[a] = sum
    end
    w.each_pair{|k,v| w[k] = v / norm}
  end

  # build the ranks for each DMs corresponding to eq_3.4
  def delta(dms, count)
    ranks = {}
    dms.each_pair do |d, values|
      ranks[d] = {}
      tmp = values.values.sort.reverse
      dms[d].each_pair do |k, v|
        ranks[d][k] = count.to_f / (tmp.index(v)+1)
      end
    end
    ranks
  end

  # Return matrix corresponding to eq_3.1
  # => Params:
  # => decision_weights: map from dm to his decision weight
  def preferential_difference(decision_weights, alternatives)
    theta = {}
    sorted_alts = alternatives.sort
    decision_weights.each_pair do |k, v|
      theta[k] = {}
      sorted_alts.each_with_index do |i_v, i|
        sorted_alts.each_with_index do |j_v, j|
          if j > i
            theta[k].include?(sorted_alts[i]) ? theta[k][sorted_alts[i]][sorted_alts[j]] = (v[sorted_alts[i]] - v[sorted_alts[j]]).abs : (theta[k][sorted_alts[i]] = {sorted_alts[j] => (v[sorted_alts[i]] - v[sorted_alts[j]]).abs })
          end
        end
      end
    end
    theta
  end


  def calcFinalDecision(problem, user)
    
    # take the trusted user evaluation by default if the user delegate his power to some one else
    delegated = user.delegated_user(problem)
    user = User.find(user.trusts.where(:delegate => true).first.to) if delegated
    
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