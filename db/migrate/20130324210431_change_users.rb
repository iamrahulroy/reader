class ChangeUsers < ActiveRecord::Migration
  def change
    change_column :users, :email, :string, :default => ""
    change_column :users, :name, :string
    change_column :users, :encrypted_password, :string, :default => ""
  end

end
