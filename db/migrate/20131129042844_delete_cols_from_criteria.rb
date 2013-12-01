class DeleteColsFromCriteria < ActiveRecord::Migration
  def change
    remove_column :criteria, :alternatives_matrix
    remove_column :criteria, :alternatives_value
  end
end
