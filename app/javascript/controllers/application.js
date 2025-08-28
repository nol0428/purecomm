import { Application } from "@hotwired/stimulus"

export const application = Application.start()

// Optional: enable logs
// application.debug = true

// Expose globally so we can check on Heroku
window.Stimulus = application
