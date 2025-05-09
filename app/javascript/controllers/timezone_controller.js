import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.setTimezone()
  }

  setTimezone() {
    const timezone = Intl.DateTimeFormat().resolvedOptions().timeZone
    document.cookie = `browser_timezone=${timezone}; path=/; max-age=${60 * 60 * 24 * 365}` // 1 year
  }
}
