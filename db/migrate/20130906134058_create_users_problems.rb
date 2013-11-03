class CreateUsersProblems < ActiveRecord::Migration
  def change
    create_table :users_problems do |t|
      t.references  :user,    index: true
      t.references  :problem, index: true
      t.boolean     :owner
    end
  end
end
