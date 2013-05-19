require 'spec_helper'

describe ApplicationController do

  describe "GET index" do

    it 'triggers an UpdateUserSubscriptions job' do
      pending
      get :index
      Timecop.travel(20.minutes)
      get :index
      UpdateUserSubscriptions.should_receive(:perform_async)
    end

    it 'does not trigger an UpdateUserSubscriptions job if user was last seen less than 15 minutes ago' do
      pending
      get :index
      Timecop.travel(2.minutes)
      get :index
      UpdateUserSubscriptions.should_not_receive(:perform_async)
    end

  end

end
