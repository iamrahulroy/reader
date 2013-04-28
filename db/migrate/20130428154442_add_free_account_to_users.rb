class AddFreeAccountToUsers < ActiveRecord::Migration
  def change
    add_column :users, :free_account, :boolean, :default => false
  end
end
