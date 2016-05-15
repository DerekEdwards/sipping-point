class Users::SessionsController < Devise::SessionsController
# before_filter :configure_sign_in_params, only: [:create]

  #GET /resource/sign_in
  #def new
  #  super
  #end

  # POST /resource/sign_in
  def create
    super
    current_user.confirmed = true
    current_user.save 
  end

  def google_create
    #self.resource = warden.authenticate!(auth_options)
    current_user = google_verify params['id_token']
    
    if current_user 
      puts 'success so far'
      current_user.confirmed = true
      current_user.save 
      sign_in(:user, current_user)
      yield current_user if block_given?
      respond_with current_user, location: after_sign_in_path_for(current_user)
    end 
    #set_flash_message!(:notice, :signed_in)

  end

  # DELETE /resource/sign_out
  # def destroy
  #   super
  # end

  protected

  def google_verify id_token

    user_hash = GoogleAuth.new.verify id_token

    unless user_hash[:result]
      return nil
    end

    user = User.find_or_create_by(email: user_hash[:email].downcase) do |u|
      u.password = u.password_confirmation = Devise.friendly_token.first(8)
    end

    return user

  end


  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_in_params
  #   devise_parameter_sanitizer.for(:sign_in) << :attribute
  # end
end
