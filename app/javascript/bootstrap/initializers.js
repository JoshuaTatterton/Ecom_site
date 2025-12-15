import "bootstrap/bootstrap.bundle.min"

const dummyEvent = { target: document }

// Tooltips
export const initializeTooltips = (event = dummyEvent) => {
  const tooltipTriggerList = event.target.querySelectorAll("[data-bs-toggle='tooltip']")
  const tooltipList = [...tooltipTriggerList].map(tooltipTriggerEl => new bootstrap.Tooltip(tooltipTriggerEl))
}

// Collapse
export const initializeSelectCollapses = (event = dummyEvent) => {
  const collapseElementList = event.target.querySelectorAll("select[data-bs-toggle='collapse']")

  collapseElementList.forEach(collapseEl => {
    const initialValue = collapseEl.value

    // Generate bootstrap toggles
    const collapseObjects = {}
    collapseEl.querySelectorAll("option[data-bs-target]").forEach(option => {
      const selector = option.getAttribute("data-bs-target")
      if (!collapseObjects[selector]) {
        const element = event.target.querySelector(selector)

        if (!!element) {
          collapseObjects[selector] = new bootstrap.Collapse(element, { toggle: false })

          // Initial collapse
          if (initialValue === option.value) {
            collapseObjects[selector].show()
          }
        }
      }
    })

    // Add event listener
    collapseEl.addEventListener("change", (e) => {
      const selector = e.target.querySelector(`[value='${e.target.value}']`).getAttribute("data-bs-target")

      if (!!selector) {
        collapseObjects[selector].show()
      }

      const unusedSelectors = Object.keys(collapseObjects).filter((s) => s !== selector )
      unusedSelectors.forEach((s) => collapseObjects[s].hide())
    })
  })
}

export const initializeValueCollapses = (event = dummyEvent) => {
  const collapseElementList = event.target.querySelectorAll("input[data-bs-toggle='value_collapse']")

  collapseElementList.forEach(collapseEl => {
    const target = collapseEl.getAttribute("data-bs-target")
    const targetEls = document.querySelectorAll(target)
    const valuesAttr = collapseEl.getAttribute("data-bs-values")

    if (!!targetEls && !!valuesAttr) {
      const values = valuesAttr.split(",")
      const collapseTargets = [...targetEls].map((el) => new bootstrap.Collapse(el, { toggle: false }))

      // Add event listener
      collapseEl.addEventListener("change", (e) => {
        if (values.includes(e.target.value)) {
          collapseTargets.forEach((target) => target.show())
        } else {
          collapseTargets.forEach((target) => target.hide())
        }
      })
    }
  })
}

// Tabs
export const initializeTabs = (event = dummyEvent) => {
  const tabTriggerList = event.target.querySelectorAll("[data-bs-toggle='tab']")
  const tabList = [...tabTriggerList].map(tabTriggerEl => new bootstrap.Tab(tabTriggerEl))
}
