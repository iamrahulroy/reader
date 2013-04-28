class AddCommentCountsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :has_new_comments_count, :integer
    add_column :users, :commented_count, :integer
  end
end
