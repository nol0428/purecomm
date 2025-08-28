import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.scrollToBottom()
    // Re-run on Turbo Stream updates
    document.addEventListener("turbo:before-stream-render", this._onStream)
  }

  disconnect() {
    document.removeEventListener("turbo:before-stream-render", this._onStream)
  }

  _onStream = (event) => {
    // Defer until after the stream renders
    requestAnimationFrame(() => this.scrollToBottom())
  }

  scrollToBottom() {
    // container is the element with data-controller="autoscroll"
    this.element.scrollTop = this.element.scrollHeight
  }
}
