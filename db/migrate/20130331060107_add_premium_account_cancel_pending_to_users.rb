class AddPremiumAccountCancelPendingToUsers < ActiveRecord::Migration
  def change
    add_column :users, :premium_account_cancel_pending, :boolean, :default => false
  end
end
