require 'spec_helper'

describe ApplicationController do

  describe "GET index" do

    let(:user) { User.create! name: "Bob", email: "bob@example.com", password: '123456' }

    it 'should trigger an UpdateUserSubscriptions job' do
      pending

      UpdateUserSubscriptions.should_receive(:perform_async)
      true.should == false
    end

  end

end
