class CreateCriteria < ActiveRecord::Migration
  def change
    create_table :criteria do |t|
      t.string      :name
      t.text        :desc
      t.string      :tw_hash
      t.references  :problem, index: true
      t.text        :alternatives_matrix
      t.text        :alternatives_value
      t.decimal     :weight

      t.timestamps
    end
  end
end
