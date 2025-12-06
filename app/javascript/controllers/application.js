import { Application } from "@hotwired/stimulus"
import { initializeTooltips, initializeSelectCollapses } from "bootstrap/initializers"

const application = Application.start()

// Configure Stimulus development experience
application.debug = false
window.Stimulus   = application

initializeTooltips()
document.addEventListener("turbo:frame-render", initializeTooltips)
initializeSelectCollapses()
document.addEventListener("turbo:frame-render", initializeSelectCollapses)

export { application }
