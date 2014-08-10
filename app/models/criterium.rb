class Criterium < ActiveRecord::Base
  
  has_many :subcriteria, class_name: "Criterium", foreign_key: "parent_id"
 
  belongs_to :parent, class_name: "Criterium"
  
  belongs_to :problem
  has_many :evaluations
  
  validates :name, uniqueness: true
  validates :name, :desc, presence: true
  
  scope :active, where(:reject => false)
  scope :firstLevel, where(:reject => false, :parent_id => -1)
  
  def active?
    !self.reject
  end
  
  def firstLevel?
    !self.reject && self.parent_id == -1
  end
  
  def isParent?
    parent = false
    Criterium.where(:parent_id => self.id).each do |c|
      parent = (!c.reject or parent)
    end
    parent
  end
  
  def isLeaf
    !self.reject && !hasSubcriteria?
  end
  
  def hasSubcriteria?
    self.subcriteria.where(:reject => false).count > 0
  end
  
  def hasSubcriteriaToEvaluate?
    self.subcriteria.where(:reject => false).count > 1
  end
  
  
  
  def self.w_diff(problem)
    dms           = {}
    problem.users.each do |u| 
      dms[u.id] = calcFinalDecision(problem, u)
    end
    # theta = preferential_difference(dms)
    alts_name_id = {}
    problem.alternatives.where(:reject => false).map {|a| alts_name_id[a.name] = a.id}
    criteria = problem.criteria.select(&:isLeaf)
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
        puts "--- #{alts_eval}"
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
  
  def self.calcFinalDecision(problem, user)
    alternatives  = problem.alternatives.where(:reject => false).count
    criteria = problem.criteria.select(&:active?).reject(&:isParent?)  # TODO: check &:active & &:isparent
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
