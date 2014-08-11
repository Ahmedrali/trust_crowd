class CreateTrusts < ActiveRecord::Migration
  def change
    create_table :trusts do |t|
      t.references :user, index: true
      t.integer :to
      t.references :problem, index: true

      t.timestamps
    end
  end
end
