class AddTwitterToItems < ActiveRecord::Migration
  def change
    add_column :items, :sent_to_twitter, :boolean
    add_column :items, :twitter_id, :string
  end
end
