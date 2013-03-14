class AddItemViewToGroups < ActiveRecord::Migration
  def change
    add_column :groups, :item_view, :string
  end
end
