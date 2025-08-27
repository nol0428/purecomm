import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="disable-inputs"
export default class extends Controller {
  static targets = ["input"]
  connect() {
    this.inputTargets.forEach((input) => {
      if (!input.checked) {
          input.disabled = true
      }
    })
  }
}
