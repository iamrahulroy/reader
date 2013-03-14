class AddFacebookToItems < ActiveRecord::Migration
  def change
    add_column :items, :sent_to_facebook, :boolean
    add_column :items, :facebook_id, :string
  end
end
