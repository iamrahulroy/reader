class Errorsfeeds < ActiveRecord::Migration
  def change
    add_column :feeds, :errors, :integer, :default => 0
  end
end
