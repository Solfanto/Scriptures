import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  connect () {
    // Auto-dismiss success messages after 5 seconds
    if (this.element.classList.contains('flash-message--notice')) {
      this.autoDismissTimeout = setTimeout(() => {
        this.dismiss()
      }, 5000)
    }
  }

  disconnect () {
    // Clean up timeout if the element is removed
    if (this.autoDismissTimeout) {
      clearTimeout(this.autoDismissTimeout)
    }
  }

  dismiss () {
    // Clear auto-dismiss timeout if manually dismissed
    if (this.autoDismissTimeout) {
      clearTimeout(this.autoDismissTimeout)
    }

    // Add dismissing class to trigger CSS animation
    this.element.classList.add('flash-message--dismissing')

    // Remove element after animation completes
    setTimeout(() => {
      this.element.remove()
    }, 400) // Match CSS animation duration
  }
}
