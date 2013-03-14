class AddTwitterAndFacebookShareOptionsToUser < ActiveRecord::Migration
  def change
    add_column :users, :share_to_twitter, :boolean
    add_column :users, :share_to_facebook, :boolean
  end
end
