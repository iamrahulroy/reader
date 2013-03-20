class EntryGuid < ActiveRecord::Base
  attr_accessible :guid, :feed_id
  has_one :entry
end
