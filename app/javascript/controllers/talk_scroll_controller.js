import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="talk-scroll"
export default class extends Controller {
  connect() {
    this.element.scrollIntoView();
  }
}
