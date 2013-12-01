class CreateEvaluations < ActiveRecord::Migration
  def change
    create_table :evaluations do |t|
      t.references :user
      t.references :criteria
      t.text :alternatives_matrix
      t.text :alternatives_value

      t.timestamps
    end
  end
end
