class AddLastTweetIdToCriteria < ActiveRecord::Migration
  def change
    add_column :criteria, :last_tweet_id, :integer, :limit => 8
  end
end
