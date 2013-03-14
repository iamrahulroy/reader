class AddFavoriteToSubscriptions < ActiveRecord::Migration
  def change
    add_column :subscriptions, :favorite, :boolean, :default => false
  end
end
