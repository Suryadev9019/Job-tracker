class ProfilesController < ApplicationController
  before_action :authenticate_user!

  def edit
    @user = current_user
  end

  def update
    @user = current_user
    if @user.update(progile_params)
      redirect_to rooth_path,notice: "Profile updated successfully"
    else
      render :edit
  end
end
