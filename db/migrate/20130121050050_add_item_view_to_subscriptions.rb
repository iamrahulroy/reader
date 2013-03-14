class AddItemViewToSubscriptions < ActiveRecord::Migration
  def change
    add_column :subscriptions, :item_view, :string
  end
end
