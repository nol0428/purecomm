import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { currentUserId: Number }

  connect() {
    this.tagAll()
    this.scrollToBottom()

    this.observer = new MutationObserver((mutations) => {
      for (const m of mutations) {
        m.addedNodes.forEach((node) => {
          if (node.nodeType === 1 && node.matches?.("li.talk-row")) {
            this.tagRow(node)
          }
        })
      }
      this.scrollToBottom()
    })
    this.observer.observe(this.element, { childList: true })
  }

  disconnect() {
    this.observer?.disconnect()
  }

  tagAll() {
    this.element.querySelectorAll("li.talk-row").forEach((el) => this.tagRow(el))
  }

  tagRow(el) {
    const authorId = Number(el.getAttribute("data-author-id"))
    el.classList.remove("me", "them")
    if (Number.isFinite(this.currentUserIdValue)) {
      el.classList.add(authorId === this.currentUserIdValue ? "me" : "them")
    }
  }

  scrollToBottom() {
    const container = document.scrollingElement || document.documentElement
    container.scrollTo({ top: container.scrollHeight, behavior: "instant" })
  }
}
// test comment
