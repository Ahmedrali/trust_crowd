class CreateCriteriaEvaluations < ActiveRecord::Migration
  def change
    create_table :criteria_evaluations do |t|
      t.references :problem, index: true
      t.references :criterium, index: true
      t.references :user, index: true
      t.text :criteria_matrix
      t.text :criteria_value

      t.timestamps
    end
  end
end
