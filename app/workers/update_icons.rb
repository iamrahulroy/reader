class UpdateIcons
  include Sidekiq::Worker
  sidekiq_options :queue => :icons
  def perform
    UpdateIcons.perform_in 12.hours
    Feed.get_icons
  end

end