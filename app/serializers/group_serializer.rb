class GroupSerializer < ActiveModel::Serializer
  attributes :id, :label, :weight, :key, :open
end
