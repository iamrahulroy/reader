class Users::RegistrationsController < Devise::RegistrationsController
  def create
    build_resource
    @user = resource
    agreed = params[:user]['agree_to_terms'] == 'on'
    unless agreed
      render :json => {errors: {:terms => true}}
      return
    end
    if resource.save && agreed
      if resource.active_for_authentication?
        sign_in(resource_name, resource)
        resource.send_welcome_email
        render_user
      else
        expire_session_data_after_sign_in!
        render_user
      end
    else
      render :json => {errors: @user.errors}
    end
  end

  private
    def render_user
      render :json => @user, :serializer => UserSerializer, :root => false
    end
end
