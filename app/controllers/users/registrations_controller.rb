class Users::RegistrationsController < Devise::RegistrationsController
  def create
    build_resource
    @user = resource

    if resource.save
      if resource.active_for_authentication?
        sign_in(resource_name, resource)
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