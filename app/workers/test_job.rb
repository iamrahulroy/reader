class TestJob
  include Sidekiq::Worker
  sidekiq_options :queue => :critical
  #include ::NewRelic::Agent::Instrumentation::ControllerInstrumentation
  def perform

    result = ActiveRecord::Base.connection.execute <<HERESTR
select count(*) from test_records;
HERESTR
    ap result.first

    rs = rand(36**7..36**200).to_s(36)
    result = ActiveRecord::Base.connection.execute <<HERESTR
INSERT INTO "test_records" ("title", "created_at", "updated_at") VALUES ('#{rs}', '#{DateTime.current.to_s}', '#{DateTime.current.to_s}') RETURNING "id";
HERESTR

    ap result.first
  end

  #add_transaction_tracer :perform, :category => :task
end
