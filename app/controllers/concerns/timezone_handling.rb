module TimezoneHandling
  extend ActiveSupport::Concern

  included do
    around_action :set_timezone
  end

  private

  def set_timezone
    timezone = cookies[:browser_timezone] || "Asia/Taipei"
    Time.use_zone(timezone) do
      yield
    end
  end
end
