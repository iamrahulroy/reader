class ImportOpml
  include OpmlImporter
  @queue = :opml
  def self.perform(filetext, user_id)
    self.new.import_opml filetext, user_id
    user = User.find(user_id)
    PlusMailer.opml_imported(user).deliver
  rescue LibXML::XML::Error => e

  end

end