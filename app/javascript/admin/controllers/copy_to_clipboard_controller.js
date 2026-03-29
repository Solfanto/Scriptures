import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['button', 'message']
  static values = {
    text: String,
    copiedLabel: { type: String, default: 'Copied!' }
  }

  async copy(event) {
    event.preventDefault()

    const textToCopy = this.textValue || this.element.dataset.copyValue || ''

    if (!textToCopy) {
      console.error('No text to copy')
      return
    }

    try {
      await navigator.clipboard.writeText(textToCopy)

      // Show validation message
      if (this.hasMessageTarget) {
        this.messageTarget.textContent = this.copiedLabelValue
        this.messageTarget.classList.remove('hidden')

        setTimeout(() => {
          this.messageTarget.classList.add('hidden')
        }, 2000)
      } else {
        // Fallback: show message on button if no message target
        if (this.hasButtonTarget) {
          const originalText = this.buttonTarget.textContent
          this.buttonTarget.textContent = this.copiedLabelValue
          this.buttonTarget.classList.add('btn--success')

          setTimeout(() => {
            this.buttonTarget.textContent = originalText
            this.buttonTarget.classList.remove('btn--success')
          }, 2000)
        }
      }
    } catch (err) {
      console.error('Failed to copy to clipboard:', err)
      // Fallback: select text if clipboard API fails
      const textArea = document.createElement('textarea')
      textArea.value = textToCopy
      textArea.style.position = 'fixed'
      textArea.style.opacity = '0'
      document.body.appendChild(textArea)
      textArea.select()
      try {
        document.execCommand('copy')
        if (this.hasMessageTarget) {
          this.messageTarget.textContent = this.copiedLabelValue
          this.messageTarget.classList.remove('hidden')
          setTimeout(() => {
            this.messageTarget.classList.add('hidden')
          }, 2000)
        }
      } catch (fallbackErr) {
        console.error('Fallback copy failed:', fallbackErr)
      }
      document.body.removeChild(textArea)
    }
  }
}
