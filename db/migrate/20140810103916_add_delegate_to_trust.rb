class AddDelegateToTrust < ActiveRecord::Migration
  def change
    add_column :trusts, :delegate, :boolean, :default => false 
  end
end
