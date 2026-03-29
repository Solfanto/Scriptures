import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['input', 'dropdown', 'option', 'selectedList', 'hiddenField']
  static values = {
    placeholder: String,
    noCountriesLabel: String,
    fieldName: String,
    modelName: String
  }

  async setupCountries () {
    try {
      // Try to fetch countries from the server using the countries gem
      const response = await fetch('/admin/countries.json')
      const data = await response.json()
      this.countries = data.countries || []
    } catch (error) {
      console.error('Failed to load countries:', error)
      // Fallback to major countries if the request fails
      this.countries = [
        { code: 'US', name: 'United States of America' },
        { code: 'CA', name: 'Canada' },
        { code: 'GB', name: 'United Kingdom' },
        { code: 'DE', name: 'Germany' },
        { code: 'FR', name: 'France' },
        { code: 'IT', name: 'Italy' },
        { code: 'ES', name: 'Spain' },
        { code: 'NL', name: 'Netherlands' },
        { code: 'BE', name: 'Belgium' },
        { code: 'CH', name: 'Switzerland' },
        { code: 'AT', name: 'Austria' },
        { code: 'SE', name: 'Sweden' },
        { code: 'NO', name: 'Norway' },
        { code: 'DK', name: 'Denmark' },
        { code: 'FI', name: 'Finland' },
        { code: 'IE', name: 'Ireland' },
        { code: 'PT', name: 'Portugal' },
        { code: 'GR', name: 'Greece' },
        { code: 'PL', name: 'Poland' },
        { code: 'CZ', name: 'Czechia' },
        { code: 'HU', name: 'Hungary' },
        { code: 'SK', name: 'Slovakia' },
        { code: 'SI', name: 'Slovenia' },
        { code: 'HR', name: 'Croatia' },
        { code: 'RO', name: 'Romania' },
        { code: 'BG', name: 'Bulgaria' },
        { code: 'LT', name: 'Lithuania' },
        { code: 'LV', name: 'Latvia' },
        { code: 'EE', name: 'Estonia' },
        { code: 'LU', name: 'Luxembourg' },
        { code: 'MT', name: 'Malta' },
        { code: 'CY', name: 'Cyprus' },
        { code: 'JP', name: 'Japan' },
        { code: 'KR', name: 'South Korea' },
        { code: 'CN', name: 'China' },
        { code: 'IN', name: 'India' },
        { code: 'AU', name: 'Australia' },
        { code: 'NZ', name: 'New Zealand' },
        { code: 'SG', name: 'Singapore' },
        { code: 'HK', name: 'Hong Kong' },
        { code: 'TW', name: 'Taiwan' },
        { code: 'TH', name: 'Thailand' },
        { code: 'MY', name: 'Malaysia' },
        { code: 'ID', name: 'Indonesia' },
        { code: 'PH', name: 'Philippines' },
        { code: 'VN', name: 'Viet Nam' },
        { code: 'BR', name: 'Brazil' },
        { code: 'AR', name: 'Argentina' },
        { code: 'MX', name: 'Mexico' },
        { code: 'RU', name: 'Russia' },
        { code: 'UA', name: 'Ukraine' },
        { code: 'LA', name: 'Laos' },
        { code: 'KH', name: 'Cambodia' },
        { code: 'MN', name: 'Mongolia' },
        { code: 'IL', name: 'Israel' },
        { code: 'TR', name: 'Turkey' },
        { code: 'ZA', name: 'South Africa' }
      ].sort((a, b) => a.name.localeCompare(b.name))
    }

    this.filteredCountries = [...this.countries]
    this.renderOptions()
  }

  getSelectedCodes () {
    return Array.from(this.hiddenFieldTargets).map(field => field.value).filter(Boolean)
  }

  toggleDropdown () {
    const isVisible = this.dropdownTarget.classList.contains('countries-select__dropdown--visible')

    if (isVisible) {
      this.hideDropdown()
    } else {
      this.showDropdown()
    }
  }

  async showDropdown () {
    // Load countries if not already loaded
    if (!this.countries) {
      await this.setupCountries()
    }

    this.dropdownTarget.classList.add('countries-select__dropdown--visible')
    this.inputTarget.focus()
  }

  hideDropdown () {
    this.dropdownTarget.classList.remove('countries-select__dropdown--visible')
    this.inputTarget.value = ''
    this.filteredCountries = [...this.countries]
    this.renderOptions()
  }

  filter (event) {
    const query = event.target.value.toLowerCase()
    const selectedCodes = this.getSelectedCodes()

    this.filteredCountries = this.countries.filter(country => {
      const matchesQuery = country.name.toLowerCase().startsWith(query) ||
                           country.code.toLowerCase().startsWith(query)
      const notSelected = !selectedCodes.includes(country.code)
      return matchesQuery && notSelected
    })

    this.renderOptions()
    this.showDropdown()
  }

  selectCountry (event) {
    const code = event.currentTarget.dataset.code
    const name = event.currentTarget.dataset.name

    // Check if already selected
    if (this.getSelectedCodes().includes(code)) {
      return
    }

    // Add hidden field
    const hiddenField = document.createElement('input')
    hiddenField.type = 'hidden'
    hiddenField.name = `${this.modelNameValue}[${this.fieldNameValue}][]`
    hiddenField.value = code
    hiddenField.dataset.countriesSelectTarget = 'hiddenField'
    this.element.appendChild(hiddenField)

    // Add selected item
    this.addSelectedItem(code, name)

    // Clear input and hide dropdown
    this.inputTarget.value = ''
    this.hideDropdown()

    // Trigger change event for form validation
    hiddenField.dispatchEvent(new Event('change', { bubbles: true }))
  }

  removeCountry (event) {
    const code = event.currentTarget.dataset.code

    // Remove hidden field
    const hiddenField = Array.from(this.hiddenFieldTargets).find(field => field.value === code)
    if (hiddenField) {
      hiddenField.remove()
    }

    // Remove selected item
    const selectedItem = this.selectedListTarget.querySelector(`[data-code="${code}"]`)
    if (selectedItem) {
      selectedItem.remove()
    }

    // Show empty message if no countries selected
    if (this.getSelectedCodes().length === 0) {
      this.showEmptyMessage()
    }

    // Update dropdown to show removed country
    this.filteredCountries = [...this.countries]
    this.renderOptions()
  }

  addSelectedItem (code, name) {
    // Remove empty message if present
    const emptyMessage = this.selectedListTarget.querySelector('.countries-select__selected-empty')
    if (emptyMessage) {
      emptyMessage.remove()
    }

    const item = document.createElement('div')
    item.className = 'countries-select__selected-item'
    item.dataset.code = code
    item.innerHTML = `
      <span class="countries-select__selected-name">${name}</span>
      <button type="button" class="countries-select__selected-remove" data-action="click->countries-select#removeCountry" data-code="${code}">
        <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"/>
        </svg>
      </button>
    `
    this.selectedListTarget.appendChild(item)
  }

  showEmptyMessage () {
    if (this.selectedListTarget.querySelector('.countries-select__selected-empty')) {
      return
    }
    const emptyMessage = document.createElement('div')
    emptyMessage.className = 'countries-select__selected-empty'
    emptyMessage.textContent = 'No countries selected'
    this.selectedListTarget.appendChild(emptyMessage)
  }

  renderOptions () {
    this.dropdownTarget.innerHTML = ''
    const selectedCodes = this.getSelectedCodes()

    // Filter out already selected countries
    const availableCountries = this.filteredCountries.filter(country => !selectedCodes.includes(country.code))

    if (availableCountries.length === 0) {
      const noResults = document.createElement('div')
      noResults.className = 'countries-select__no-results'
      noResults.textContent = this.noCountriesLabelValue || 'No countries found'
      this.dropdownTarget.appendChild(noResults)
      return
    }

    availableCountries.forEach(country => {
      const option = document.createElement('div')
      option.className = 'countries-select__option'
      option.dataset.code = country.code
      option.dataset.name = country.name
      option.dataset.action = 'click->countries-select#selectCountry'

      option.innerHTML = `
        <span class="countries-select__option-name">${country.name}</span>
        <span class="countries-select__option-code">${country.code}</span>
      `

      this.dropdownTarget.appendChild(option)
    })
  }

  // Handle keyboard navigation
  keydown (event) {
    if (event.key === 'Escape') {
      this.hideDropdown()
    } else if (event.key === 'ArrowDown') {
      event.preventDefault()
      this.navigateOptions(1)
    } else if (event.key === 'ArrowUp') {
      event.preventDefault()
      this.navigateOptions(-1)
    } else if (event.key === 'Enter') {
      event.preventDefault()
      const highlighted = this.dropdownTarget.querySelector('.countries-select__option--highlighted')
      if (highlighted) {
        highlighted.click()
      }
    }
  }

  navigateOptions (direction) {
    const options = this.dropdownTarget.querySelectorAll('.countries-select__option')
    const highlighted = this.dropdownTarget.querySelector('.countries-select__option--highlighted')

    let newIndex = 0

    if (highlighted) {
      const currentIndex = Array.from(options).indexOf(highlighted)
      newIndex = currentIndex + direction
      highlighted.classList.remove('countries-select__option--highlighted')
    }

    // Wrap around
    if (newIndex < 0) newIndex = options.length - 1
    if (newIndex >= options.length) newIndex = 0

    if (options[newIndex]) {
      options[newIndex].classList.add('countries-select__option--highlighted')
      options[newIndex].scrollIntoView({ block: 'nearest' })
    }
  }

  // Handle clicking outside to close dropdown
  windowClick (event) {
    if (!this.element.contains(event.target)) {
      this.hideDropdown()
    }
  }

  connect () {
    document.addEventListener('click', this.windowClick.bind(this))
  }

  disconnect () {
    document.removeEventListener('click', this.windowClick.bind(this))
  }
}
