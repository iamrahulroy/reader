class Subscriptions < ActiveRecord::Migration
  def change
    add_column :subscriptions, :sort, :string
  end
end
