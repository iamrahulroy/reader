class CloseIdleConnection
  include Sidekiq::Worker
  sidekiq_options :queue => :critical
  include ::NewRelic::Agent::Instrumentation::ControllerInstrumentation
  def perform
    ActiveRecord::Base.connection.execute <<SQL
SELECT pg_terminate_backend(pid)
    FROM pg_stat_activity
    WHERE state = 'idle in transaction'
      AND state_change < current_timestamp - INTERVAL '1' MINUTE;
SQL

    self.class.perform_in(1.minute)

  end

  add_transaction_tracer :perform, :category => :task
end