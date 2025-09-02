// app/javascript/controllers/index.js
import { Application } from "@hotwired/stimulus"
import { eagerLoadControllersFrom } from "@hotwired/stimulus-loading"

window.Stimulus = Application.start()
// Reuse the global Stimulus app if it's already started elsewhere,
// otherwise start a new one. This avoids double-start problems.
const application = window.Stimulus || Application.start()

// Auto-register every * _controller.js in this folder
eagerLoadControllersFrom("controllers", application)

// Optional export; harmless if unused
export { application }

window.Stimulus = application
