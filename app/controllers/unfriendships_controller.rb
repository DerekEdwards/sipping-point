class UnfriendshipsController < ApplicationController
 
 
  def create

    @user= User.find(params[:user_id].to_i)
    @unfriend = User.find(params[:unfriend_id].to_i)
    unfriendship = Unfriendship.where(user: @user, unfriend: @unfriend).first_or_create
    unfriendship.save

    render json: {message: 'deleted unfriendship, user: ' + @user.id.to_s + ' unfriend: ' + @unfriend.id.to_s}

  end

end
