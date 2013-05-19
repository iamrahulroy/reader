class EntryGuid < ActiveRecord::Base
  attr_accessible :guid, :source_id, :source_type
  has_one :entry
  belongs_to :source, :polymorphic => true
end
