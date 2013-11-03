class CreateProblems < ActiveRecord::Migration
  def change
    create_table :problems do |t|
      t.string  :name
      t.text    :desc
      t.string  :tw_hash
      t.string  :status # pending - active - closed

      t.timestamps
    end
  end
end
