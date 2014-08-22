class CreatePendingCriteriaEvaluations < ActiveRecord::Migration
  def change
    create_table :pending_criteria_evaluations do |t|
      t.references :problem, index: true
      t.references :criterium, index: true
      t.references :user, index: true
      t.boolean :decision

      t.timestamps
    end
  end
end
