class CreatePendingAlternativesEvaluations < ActiveRecord::Migration
  def change
    create_table :pending_alternatives_evaluations do |t|
      t.references :problem, index: true
      t.references :alternative, index: true
      t.references :user, index: true
      t.boolean :decision

      t.timestamps
    end
  end
end
