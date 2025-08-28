import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    // Jump to bottom on first load
    this.scrollToBottom()

    // Watch this element for new children (messages being appended)
    this.observer = new MutationObserver(() => this.scrollToBottom())
    this.observer.observe(this.element, { childList: true, subtree: true })

    // Also scroll after a successful Turbo form submit (user send)
    document.addEventListener("turbo:submit-end", this.onSubmitEnd)
  }

  disconnect() {
    if (this.observer) this.observer.disconnect()
    document.removeEventListener("turbo:submit-end", this.onSubmitEnd)
  }

  onSubmitEnd = (event) => {
    // If the form that submitted lives near the chat, give the DOM a tick then scroll
    requestAnimationFrame(() => this.scrollToBottom())
  }

  scrollToBottom() {
    const el = this.element
    // tiny delay ensures the appended DOM is painted before we measure
    requestAnimationFrame(() => {
      el.scrollTop = el.scrollHeight
    })
  }
}
