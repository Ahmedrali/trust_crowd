class AddRejectToCriteria < ActiveRecord::Migration
  def change
    add_column :criteria, :reject, :boolean, :default => false
  end
end
