import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['field', 'generateButton', 'copyButton', 'toggleButton']
  static values = { copiedLabel: String }

  connect () {
    this.setupButtons()
  }

  setupButtons () {
    // Hide copy button initially
    if (this.hasCopyButtonTarget) {
      this.copyButtonTarget.style.display = 'none'
    }
  }

  generatePassword () {
    const password = this.createSecurePassword()

    // Set the field value
    this.fieldTarget.value = password

    // Change field type to text so password is visible
    this.fieldTarget.type = 'text'

    // Show copy button and toggle button
    if (this.hasCopyButtonTarget) {
      this.copyButtonTarget.style.display = 'inline-flex'
    }
    if (this.hasToggleButtonTarget) {
      this.toggleButtonTarget.style.display = 'inline-flex'
      this.dispatch('updateToggleIcon', { state: 'visible' }) // Password is visible, so show eye open
    }
  }

  async copyPassword () {
    try {
      await navigator.clipboard.writeText(this.fieldTarget.value)

      // Visual feedback
      const originalText = this.copyButtonTarget.textContent
      this.copyButtonTarget.textContent = this.copiedLabelValue || 'Copied!'
      this.copyButtonTarget.classList.add('btn--success')

      setTimeout(() => {
        this.copyButtonTarget.textContent = originalText
        this.copyButtonTarget.classList.remove('btn--success')
      }, 2000)
    } catch (err) {
      console.error('Failed to copy password:', err)
      // Fallback: select the text
      this.fieldTarget.select()
    }
  }

  createSecurePassword () {
    const length = 24
    const charset = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*'
    let password = ''

    // Ensure at least one character from each required type
    const lowercase = 'abcdefghijklmnopqrstuvwxyz'
    const uppercase = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
    const numbers = '0123456789'
    const symbols = '!@#$%^&*'

    // Add one from each category
    password += lowercase[Math.floor(Math.random() * lowercase.length)]
    password += uppercase[Math.floor(Math.random() * uppercase.length)]
    password += numbers[Math.floor(Math.random() * numbers.length)]
    password += symbols[Math.floor(Math.random() * symbols.length)]

    // Fill the rest randomly
    for (let i = 4; i < length; i++) {
      password += charset[Math.floor(Math.random() * charset.length)]
    }

    // Shuffle the password
    return password.split('').sort(() => Math.random() - 0.5).join('')
  }
}
