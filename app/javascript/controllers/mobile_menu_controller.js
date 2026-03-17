import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["menu", "overlay"]

  toggle() {
    const isOpen = !this.menuTarget.classList.contains("translate-x-full")
    if (isOpen) {
      this.close()
    } else {
      this.open()
    }
  }

  open() {
    this.menuTarget.classList.remove("translate-x-full")
    this.overlayTarget.classList.remove("hidden")
    document.body.style.overflow = "hidden"
  }

  close() {
    this.menuTarget.classList.add("translate-x-full")
    this.overlayTarget.classList.add("hidden")
    document.body.style.overflow = ""
  }
}
