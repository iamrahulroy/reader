class ImportOpml
  include Sidekiq::Worker
  include OpmlImporter
  sidekiq_options :queue => :opml
  include ::NewRelic::Agent::Instrumentation::ControllerInstrumentation
  def perform(filetext, user_id)
    import_opml filetext, user_id
    user = User.find(user_id)
    PlusMailer.opml_imported(user).deliver
  end

  add_transaction_tracer :perform, :category => :task
end