require 'spec_helper'

describe AuthorizeService do

  let(:auth_code)         {rand(36**8).to_s(36)}
  subject(:service) { AuthorizeService.new(auth_code) }
  describe "#new" do
    it "takes an auth_code" do
      pending
      service.auth_code.should be auth_code
    end
  end

  describe "#perform" do
    subject(:service)  { AuthorizeService.new(auth_code) }
    let(:access_token) { rand(36**40).to_s(36) }
    let(:account)      { rand(36**99).to_s(36) }
    let(:name)         { "Henry" }
    let(:email)        { "user@example.com" }

    before :each do
      #service.
      #  should_receive(:get_authorization).
      #  and_return({:access_token => access_token, :account => account, :profile => {:email => email, :name => name} })
    end

    it "should set the access_token, account, email, and name properties" do
      pending
      service.perform
      service.access_token.should be access_token
      service.account.should be account
      service.name.should be name
      service.email.should be email
    end

  end


end