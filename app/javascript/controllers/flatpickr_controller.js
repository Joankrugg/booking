import { Controller } from "@hotwired/stimulus"
import flatpickr from "flatpickr"

export default class extends Controller {
  static targets = ["input"]

  connect() {
    this.inputTargets.forEach((input) => {
      flatpickr(input, {
        enableTime: true,
        dateFormat: "Y-m-d H:i",
      })
    })
  }
}
