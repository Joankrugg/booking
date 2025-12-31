import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.element.querySelectorAll("input").forEach(input => {
      input.addEventListener("change", () => {
        this.element.requestSubmit()
      })
    })
  }
}