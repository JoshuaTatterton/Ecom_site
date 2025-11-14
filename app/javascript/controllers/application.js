import { Application } from "@hotwired/stimulus"
import "bootstrap/bootstrap.bundle.min"

const application = Application.start()

// Configure Stimulus development experience
application.debug = false
window.Stimulus   = application

// Tooltips
const initializeTooltips = () => {
  const tooltipTriggerList = document.querySelectorAll("[data-bs-toggle='tooltip']")
  const tooltipList = [...tooltipTriggerList].map(tooltipTriggerEl => new bootstrap.Tooltip(tooltipTriggerEl))
}

initializeTooltips()
document.addEventListener("turbo:render", initializeTooltips)

export { application }
