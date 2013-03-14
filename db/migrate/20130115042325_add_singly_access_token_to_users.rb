class AddSinglyAccessTokenToUsers < ActiveRecord::Migration
  def change
    add_column :users, :singly_account_id, :string
    add_column :users, :singly_access_token, :string
  end
end
