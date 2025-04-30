module ApplicationHelper
  include Pagy::Frontend

  def current_user
    Current.user
  end
end
