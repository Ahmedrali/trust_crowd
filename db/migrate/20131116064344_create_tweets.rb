class CreateTweets < ActiveRecord::Migration
  def change
    create_table :tweets do |t|
      t.references :problem, index: true
      t.integer :tweet_id, :limit => 8
      t.string :tw_hash
      t.integer :retweet_count
      t.string :text
      t.float :polarity
      t.datetime :created_date
      
      t.timestamps
    end
  end
end
