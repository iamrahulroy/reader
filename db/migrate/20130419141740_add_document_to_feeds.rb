class AddDocumentToFeeds < ActiveRecord::Migration
  def change
    add_column :feeds, :document, :string, :limit => 4096
  end
end
