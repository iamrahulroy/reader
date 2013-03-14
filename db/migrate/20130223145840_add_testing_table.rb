class AddTestingTable < ActiveRecord::Migration
  def change
    create_table :test_records do |t|
      t.text :title
      t.text :summary
      t.text :content
      t.datetime :published_at

      t.timestamps
    end
  end
end
