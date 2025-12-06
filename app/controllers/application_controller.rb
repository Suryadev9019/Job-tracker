class ApplicationController < ActionController::Base
  before_action :authenticate_user!
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  include Pundit

rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

private

def user_not_authorized
  flash[:alert] = "You are not authorized to perform this action."
redirect_to(request.referer || root_path)
end

def devise_controller_or_health_check?
  is_a?(Devise::SessionsController) ||
  is_a?(Devise::RegistrationsController) ||
  is_a?(Devise::PasswordsController) ||
  controller_name == 'rails/health'
end
end
