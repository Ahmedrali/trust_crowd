class CreateAlternatives < ActiveRecord::Migration
  def change
    create_table    :alternatives do |t|
      t.string      :name
      t.text        :desc
      t.string      :tw_hash
      t.decimal     :value
      t.references  :problem, index: true

      t.timestamps
    end
  end
end
