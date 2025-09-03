import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    // Scroll on first load
    this.scrollToBottom("auto")

    // Observe child list changes (append/replace children)
    this._onMutation = () => this.maybeScroll()
    this.observer = new MutationObserver(this._onMutation)
    this.observer.observe(this.element, { childList: true })

    // Scroll after form submits (user send)
    this._onSubmitEnd = () => this.scrollToBottom("smooth")
    document.addEventListener("turbo:submit-end", this._onSubmitEnd)

    // Scroll when Turbo streams replace this list
    this._onBeforeStreamRender = () => {
      // Run on next frame after DOM swaps
      this.nextFrame(() => this.maybeScroll(true))
    }
    document.addEventListener("turbo:before-stream-render", this._onBeforeStreamRender, true)

    // Track whether user is near bottom (for window scroll)
    this._onWindowScroll = () => { this._nearBottom = this.isNearBottom() }
    window.addEventListener("scroll", this._onWindowScroll, { passive: true })
    this._nearBottom = true
  }

  disconnect() {
    if (this.observer) this.observer.disconnect()
    document.removeEventListener("turbo:submit-end", this._onSubmitEnd)
    document.removeEventListener("turbo:before-stream-render", this._onBeforeStreamRender, true)
    window.removeEventListener("scroll", this._onWindowScroll)
  }

  // Only autoscroll if user is already near bottom, unless forced (e.g., right after replace)
  maybeScroll(force = false) {
    if (force || this.isNearBottom()) this.scrollToBottom("smooth")
  }

  // Detect if the *window* is near bottom (works even if the element itself doesn't scroll)
  isNearBottom() {
    const doc = document.documentElement
    const bottomGap = doc.scrollHeight - (window.scrollY + window.innerHeight)
    return bottomGap < 120 // px
  }

  scrollToBottom(behavior = "smooth") {
    this.nextFrame(() => {
      // Prefer scrolling the element if it has its own scrollbar; else scroll the window
      const el = this.element
      const elementScrollable = el && el.scrollHeight > el.clientHeight + 4
      if (elementScrollable) {
        el.scrollTo({ top: el.scrollHeight, behavior })
      } else {
        window.scrollTo({ top: document.documentElement.scrollHeight, behavior })
      }
    })
  }

  nextFrame(fn) {
    requestAnimationFrame(() => requestAnimationFrame(fn))
  }
}
