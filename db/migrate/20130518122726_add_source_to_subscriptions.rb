class AddSourceToSubscriptions < ActiveRecord::Migration
  def change
    add_column :subscriptions, :source_id, :integer
    add_column :subscriptions, :source_type, :string
  end
end
