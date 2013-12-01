class AddCriteriaMatrixToProblem < ActiveRecord::Migration
  def change
    add_column :problems, :criteria_matrix, :text
  end
end
