module AuthenticationHelper
  def sign_in(user)
    session = create(:session, user: user)
    # In request specs, we need to use the low-level cookie jar to set signed cookies
    jar = ActionDispatch::Request.new(Rails.application.env_config.dup).cookie_jar
    jar.signed[:session_id] = {value: session.id, httponly: true}
    cookies[:session_id] = jar[:session_id]
  end
end

RSpec.configure do |config|
  config.include AuthenticationHelper, type: :request
end
