class AddTermsToUser < ActiveRecord::Migration
  def change
    add_column :users, :agree_to_terms, :boolean, :default => false
  end
end
