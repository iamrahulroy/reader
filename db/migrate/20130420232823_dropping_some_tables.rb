class DroppingSomeTables < ActiveRecord::Migration
  def change

  	drop_table :possible_contacts if table_exists? :possible_contacts
  	drop_table :facebook_authorizations if table_exists? :facebook_authorizations
  	drop_table :facebook_contact if table_exists? :facebook_contact
  	drop_table :fetch_error if table_exists? :fetch_error
  	drop_table :test_records if table_exists? :test_records
  end
end
