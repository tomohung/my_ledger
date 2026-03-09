import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["field"]

  change() {
    this.element.requestSubmit()
  }
}
