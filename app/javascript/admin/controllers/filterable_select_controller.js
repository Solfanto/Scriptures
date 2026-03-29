import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['input', 'dropdown', 'hiddenField', 'clear']
  static values = {
    placeholder: String,
    selectedValue: String,
    selectedName: String
  }

  connect () {
    this.updateDisplay()
  }

  filter (event) {
    const query = event.target.value.toLowerCase()
    const options = this.dropdownTarget.querySelectorAll('.filterable-select__option')

    options.forEach(option => {
      const text = option.textContent.toLowerCase()
      const matches = text.includes(query)
      option.style.display = matches ? 'block' : 'none'
    })

    this.showDropdown()
  }

  showDropdown () {
    this.dropdownTarget.style.display = 'block'
  }

  hideDropdown () {
    this.dropdownTarget.style.display = 'none'
  }

  toggleDropdown () {
    if (this.dropdownTarget.style.display === 'block') {
      this.hideDropdown()
    } else {
      this.showDropdown()
    }
  }

  selectOption (event) {
    const option = event.currentTarget
    const value = option.dataset.value
    const name = option.textContent.trim()

    this.inputTarget.value = name
    this.hiddenFieldTarget.value = value

    this.hideDropdown()
    this.updateClearVisibility()
  }

  clearSelection () {
    this.inputTarget.value = ''
    this.hiddenFieldTarget.value = ''
    this.hideDropdown()
    this.updateClearVisibility()
  }

  keydown (event) {
    if (event.key === 'Escape') {
      this.hideDropdown()
    }
  }

  updateDisplay () {
    if (this.selectedValueValue && this.selectedNameValue) {
      this.inputTarget.value = this.selectedNameValue
      this.hiddenFieldTarget.value = this.selectedValueValue
    }
    this.updateClearVisibility()
  }

  updateClearVisibility () {
    if (this.hasClearTarget) {
      this.clearTarget.style.display = this.inputTarget.value ? 'block' : 'none'
    }
  }
}
