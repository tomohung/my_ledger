import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["checkbox", "selectAll", "actions", "count"]

  selectAllChanged() {
    const checked = this.selectAllTarget.checked
    this.checkboxTargets.forEach(cb => cb.checked = checked)
    this.updateUI()
  }

  checkboxChanged() {
    const all = this.checkboxTargets.length
    const checked = this.selectedIds.length
    this.selectAllTarget.checked = checked === all
    this.selectAllTarget.indeterminate = checked > 0 && checked < all
    this.updateUI()
  }

  get selectedIds() {
    return this.checkboxTargets
      .filter(cb => cb.checked)
      .map(cb => cb.value)
  }

  updateUI() {
    const count = this.selectedIds.length
    this.actionsTarget.classList.toggle("hidden", count === 0)
    this.countTarget.textContent = count
  }

  deleteSelected(event) {
    const ids = this.selectedIds
    if (ids.length === 0) return

    event.preventDefault()
    if (!confirm(`確定要刪除這 ${ids.length} 筆交易紀錄嗎？`)) return

    const form = event.target.closest("form")
    ids.forEach(id => {
      const input = document.createElement("input")
      input.type = "hidden"
      input.name = "ids[]"
      input.value = id
      form.appendChild(input)
    })
    form.requestSubmit()
  }
}
