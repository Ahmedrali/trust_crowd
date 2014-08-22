class AddPendingToCriteria < ActiveRecord::Migration
  def change
    add_column :criteria, :pending, :boolean, :default => false
  end
end
