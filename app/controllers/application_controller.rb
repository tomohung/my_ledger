class ApplicationController < ActionController::Base
  include Authentication
  include Pagy::Backend
  include Pagy::Frontend
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  def current_user
    Current.user
  end
end
