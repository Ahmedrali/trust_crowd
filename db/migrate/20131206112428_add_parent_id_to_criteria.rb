class AddParentIdToCriteria < ActiveRecord::Migration
  def change
    add_column :criteria, :parent_id, :integer, :default => -1, :index => true
  end
end
