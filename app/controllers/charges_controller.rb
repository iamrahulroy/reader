class ChargesController < ApplicationController
  #before_filter :check_reader_user
  include ApplicationHelper

  def new
    binding.pry
  end

  def create
    if real_user
      # Amount in cents
      @amount = 700

      customer = Stripe::Customer.create(
        :email => current_user.email,
        :card  => params[:stripeToken],
        :plan  => "1"
      )

      current_user.update_column(:stripe_data, customer.to_json)
      current_user.update_column(:premium_account, true)
      current_user.update_column(:stripe_customer_id, customer["subscription"]["customer"])

      flash[:notice] = "Thank you for your support!"
      redirect_to "/settings"
    else
      flash[:error] = "Session lost. Please try again."
      redirect_to "/"
    end
  rescue Stripe::CardError => e
    flash[:error] = e.message
    redirect_to "/"
  end

  def destroy
    if real_user
      cu = Stripe::Customer.retrieve(stripe_customer_id)
      response = cu.cancel_subscription

      current_user.update_column(:stripe_data, response.to_json)
      current_user.update_column(:premium_account_cancel_pending, true)
      expire_date = DateTime.strptime(response["current_period_end"].to_s,'%s')

      if response[:deleted]
        flash[:notice] = "Your premium account will expire at #{expire_date.to_s(:long_ordinal)}. Thank you for your support!"
      else
        flash[:error]  = "There has been an error. Please try again or contact team@1kpl.us"
      end
    end
    redirect_to "/settings"
  end

  protected
    def stripe_customer_id
      json = JSON.load(current_user.stripe_data)
      json["subscription"]["customer"]
    end

end
