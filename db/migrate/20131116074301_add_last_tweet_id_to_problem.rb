class AddLastTweetIdToProblem < ActiveRecord::Migration
  def change
    add_column :problems, :last_tweet_id, :integer, :limit => 8
  end
end
