class AddPendingToAlternatives < ActiveRecord::Migration
  def change
    add_column :alternatives, :pending, :boolean, :default => false
  end
end
