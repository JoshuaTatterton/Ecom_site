import { Application } from "@hotwired/stimulus"
import { initializeTooltips, initializeSelectCollapses, initializeValueCollapses, initializeTabs } from "bootstrap/initializers"

const application = Application.start()

// Configure Stimulus development experience
application.debug = false
window.Stimulus   = application

initializeTooltips()
document.addEventListener("turbo:render", initializeTooltips)
initializeSelectCollapses()
document.addEventListener("turbo:render", initializeSelectCollapses)
initializeValueCollapses()
document.addEventListener("turbo:render", initializeValueCollapses)
initializeTabs()
document.addEventListener("turbo:render", initializeTabs)

export { application }
