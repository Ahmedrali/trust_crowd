class AddRejectToAlternatives < ActiveRecord::Migration
  def change
    add_column :alternatives, :reject, :boolean, :default => false
  end
end
