import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  connect() {
    this.boundHandleKeydown = this.handleKeydown.bind(this)
    document.addEventListener('keydown', this.boundHandleKeydown)
  }

  disconnect() {
    document.removeEventListener('keydown', this.boundHandleKeydown)
  }

  handleKeydown(event) {
    // Prevent key repeat
    if (event.repeat) {
      return
    }

    // Don't navigate if user is typing in an input, textarea, or contenteditable element
    const activeElement = document.activeElement
    const isInputFocused = activeElement.tagName === 'INPUT' ||
                          activeElement.tagName === 'TEXTAREA' ||
                          activeElement.isContentEditable ||
                          activeElement.closest('[contenteditable="true"]')

    if (isInputFocused) {
      return
    }

    // Check if this element matches the pressed key
    const command = this.element.dataset.command
    if (command === event.key) {
      event.preventDefault()
      const action = this.element.dataset.commandAction || 'click'
      this.executeAction(this.element, action)
    }
  }

  executeAction(element, action) {
    switch (action) {
      case 'click':
        element.click()
        break
      case 'focus':
        element.focus()
        break
      case 'submit':
        if (element.tagName === 'FORM' || element.closest('form')) {
          const form = element.tagName === 'FORM' ? element : element.closest('form')
          form.requestSubmit()
        }
        break
      default:
        // For custom actions, dispatch a custom event
        element.dispatchEvent(new CustomEvent(`keyboard-navigation:${action}`, {
          bubbles: true,
          cancelable: true
        }))
    }
  }
}
