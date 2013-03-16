class RedesignEntries < ActiveRecord::Migration
  def change

    remove_column :entries, :sanitized_content

    add_column :entries, :processed, :boolean, :default => false
    add_column :entries, :delivered, :boolean, :default => false

  end
end