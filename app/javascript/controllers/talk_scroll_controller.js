import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    currentUserId: Number
  }

  connect() {

    this.tagAll()
    this.scrollToBottom()

    this.observer = new MutationObserver((mutations) => {
      for (const m of mutations) {
        m.addedNodes.forEach((node) => {
          if (node.nodeType === 1 && node.matches && node.matches("li.chat-bubble")) {
            this.tagBubble(node)
          }
        })
      }
      this.scrollToBottom()
    })
    this.observer.observe(this.element, { childList: true })
  }

  disconnect() {
    if (this.observer) this.observer.disconnect()
  }

  tagAll() {
    this.element.querySelectorAll("li.chat-bubble").forEach((el) => this.tagBubble(el))
  }

  tagBubble(el) {
    const authorId = Number(el.getAttribute("data-author-id"))
    el.classList.remove("me", "them")
    if (Number.isFinite(this.currentUserIdValue)) {
      el.classList.add(authorId === this.currentUserIdValue ? "me" : "them")
    }
  }

  scrollToBottom() {
    try {

      const container = document.scrollingElement || document.documentElement
      container.scrollTo({ top: container.scrollHeight, behavior: "instant" })
    } catch (_) {}
  }
}
