import { Controller } from "@hotwired/stimulus"
export default class extends Controller {
  static targets = ["organizer", "activity"]
  connect() { this.change() }
  change() {
    const organizer = this.element.querySelector('input[type="checkbox"][name="user[uses_organizing]"]')?.checked
    this.organizerTarget.hidden = !organizer
    this.activityTarget.required = organizer
  }
}
