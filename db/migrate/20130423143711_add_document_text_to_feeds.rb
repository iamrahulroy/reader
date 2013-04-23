class AddDocumentTextToFeeds < ActiveRecord::Migration
  def change
  	add_column :feeds, :document_text, :text
  end
end
