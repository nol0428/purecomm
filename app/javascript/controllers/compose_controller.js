import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["textarea", "submit"]

  connect() {
    // focus when the form appears
    this.textareaTarget?.focus()
  }

  // Clear textarea after successful Turbo Stream submit
  // (Rails fires this when create.turbo_stream renders)
  reset() {
    if (this.textareaTarget) {
      this.textareaTarget.value = ""
      this.textareaTarget.focus()
    }
  }

  // Optional: Enter = submit, Shift+Enter = newline
  keydown(event) {
    if (event.key === "Enter" && !event.shiftKey) {
      event.preventDefault()
      // Trigger submit button
      this.submitTarget?.click()
    }
  }
}
