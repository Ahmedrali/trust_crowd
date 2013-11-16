class AddLastTweetIdToAlternative < ActiveRecord::Migration
  def change
    add_column :alternatives, :last_tweet_id, :integer, :limit => 8
  end
end
