import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  submitDefault(event) {
    const identifier = event.target.getAttribute("data-identifier")
    let confirmResponse

    if (event.target.checked) {
      confirmResponse = confirm(`Are you sure you want to make ${identifier} the account default Currency?`)
    } else {
      confirmResponse = confirm(`Are you sure you want to remove ${identifier} as the default account Currency?`)
    }

    if (confirmResponse) {
      event.target.form.submit()
    } else {
      event.target.checked = !event.target.checked
    }
  }
}
