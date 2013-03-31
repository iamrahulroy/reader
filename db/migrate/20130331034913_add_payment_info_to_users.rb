class AddPaymentInfoToUsers < ActiveRecord::Migration
  def change
    add_column :users, :stripe_data, :text
    add_column :users, :premium_account, :boolean, :default => false
  end
end
