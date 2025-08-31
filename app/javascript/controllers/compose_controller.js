import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["textarea", "submit"]

  connect() {
    // focus when the form appears
    console.log("[compose] connect fired")
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

  // --- Minimal helpers to toggle the tiny thinking badge ---
  pcThinkingEl() {
    return document.getElementById("pc-thinking")
  }

  showThinking() {
    this._pcThinkingStartedAt = performance.now()
    const el = this.pcThinkingEl()
    if (el) el.hidden = false
  }

  hideThinking() {
    const el = this.pcThinkingEl()
    if (!el) return

    const MIN_MS = 800  // minimum time to keep it visible
    const started = this._pcThinkingStartedAt || performance.now()
    const elapsed = performance.now() - started
    const wait = Math.max(0, MIN_MS - elapsed)

    setTimeout(() => { el.hidden = true }, wait)
  }

  // --- Minimal helpers for error badge ---
  pcErrorEl() {
    return document.getElementById("pc-error")
  }

  pcErrorDetailEl() {
    return document.getElementById("pc-error-detail")
  }

  hideError() {
    const box = this.pcErrorEl()
    if (!box) return
    box.hidden = true
    const d = this.pcErrorDetailEl()
    if (d) d.textContent = ""
  }

  showError(msg) {
    const box = this.pcErrorEl()
    if (!box) return
    const d = this.pcErrorDetailEl()
    if (d) d.textContent = msg || ""
    box.hidden = false
  }
  checkStatus(event) {
  const { success, fetchResponse } = event.detail || {}
  if (success) return  // everything was fine

  let msg = "Please try again."
  if (fetchResponse && fetchResponse.response) {
    const r = fetchResponse.response
    msg = `Error ${r.status} ${r.statusText || ""}`.trim()
  }
  this.showError(msg)
  }
}
