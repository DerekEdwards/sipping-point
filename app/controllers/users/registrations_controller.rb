class Users::RegistrationsController < Devise::RegistrationsController
# before_filter :configure_sign_up_params, only: [:create]
# before_filter :configure_account_update_params, only: [:update]

  # GET /resource/sign_up
  def new
    
    #Check Session for errors, email, and name
    @email_error = session[:email_error]
    @password_error = session[:password_error]
    @password_confirmation_error = session[:password_confirmation_error]
    @email = session[:email]
    @name = session[:name]
    session[:email_error] = nil
    session[:password_error] = nil
    session[:password_confirmation_error] = nil 
    session[:email] = nil
    session[:name] = nil

    build_resource({})
    set_minimum_password_length
    yield resource if block_given?
    respond_with self.resource
  end

  # POST /resource
  def create
    self.resource = User.find_by(email: sign_up_params[:email], confirmed: false)

    if resource.nil?
      self.resource = User.where(email: sign_up_params[:email]).new
    end
    
    resource.name = sign_up_params[:name]
    resource.password = sign_up_params[:password]
    resource.password_confirmation = sign_up_params[:password_confirmation]

    saved = resource.save

    if saved
      if resource.active_for_authentication?
        resource.confirmed = true
        resource.save
        set_flash_message :notice, :signed_up if is_flashing_format?
        sign_up(resource_name, resource)
        respond_with resource, location: after_sign_up_path_for(resource)
      else
        set_flash_message :notice, :"signed_up_but_#{resource.inactive_message}" if is_flashing_format?
        expire_data_after_sign_in!
        respond_with resource, location: after_inactive_sign_up_path_for(resource)
      end
    else
      clean_up_passwords resource
      set_minimum_password_length

      #Save old values and set errors
      resource.errors.each do |key,value|
        session[(key.to_s + "_error").to_sym] =  value
      end
      session[:email] =  sign_up_params[:email]
      session[:name] = sign_up_params[:name]
      
      redirect_to new_user_registration_path
    end
  
  end

  # GET /resource/edit
  def edit
    super
  end

  # PUT /resource
  def update

    self.resource = resource_class.to_adapter.get!(send(:"current_#{resource_name}").to_key)
    
    prev_unconfirmed_email = resource.unconfirmed_email if resource.respond_to?(:unconfirmed_email)

    #Using Form_Tag instead of Form_For, Set Custom account_update_params
    account_update_params = custom_account_update_params params

    if account_update_params[:password_confirmation].blank? and account_update_params[:password].blank?
      account_update_params.delete(:current_password)
      resource_updated = resource.update_without_password(account_update_params)
    else
      resource_updated = update_resource(resource, account_update_params)
    end

    yield resource if block_given?
    if resource_updated
      if is_flashing_format?
        flash_key = update_needs_confirmation?(resource, prev_unconfirmed_email) ?
          :update_needs_confirmation : :updated
        set_flash_message :notice, flash_key
      end
      sign_in resource_name, resource, bypass: true
      respond_with resource, location: after_update_path_for(resource)
    else
      clean_up_passwords resource
      respond_with resource
    end
  end

  # DELETE /resource
  # def destroy
  #   super
  # end

  # GET /resource/cancel
  # Forces the session data which is usually expired after sign
  # in to be expired now. This is useful if the user wants to
  # cancel oauth signing in/up in the middle of the process,
  # removing all OAuth session data.
  # def cancel
  #   super
  # end

  # protected

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_up_params
  #   devise_parameter_sanitizer.for(:sign_up) << :attribute
  # end

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_account_update_params
  #   devise_parameter_sanitizer.for(:account_update) << :avatar_url
  # end

  # Sipping Point is using form_tag instead of form_for.  Form_tag allows for easier customization, but requires the 
  # default params to be overwritten since they are not associated with a model.
  def custom_account_update_params params
    custom_params  = {}
    [:email, :name, :avatar_url, :password, :password_confirmation, :current_password].each do |key|
      custom_params[key] = params[key]
    end
    return custom_params
  end

  # The path used after sign up.
  # def after_sign_up_path_for(resource)
  #   super(resource)
  # end

  # The path used after sign up for inactive accounts.
  # def after_inactive_sign_up_path_for(resource)
  #   super(resource)
  # end
end
