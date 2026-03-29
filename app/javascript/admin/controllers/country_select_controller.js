import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['input', 'dropdown', 'option', 'hiddenField']
  static values = {
    placeholder: String,
    selected: String,
    selectedName: String,
    noCountriesLabel: String
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

  setupInitialValue () {
    if (this.selectedValue) {
      // Set the hidden field value
      this.hiddenFieldTarget.value = this.selectedValue

      // Set the input field value
      const country = { code: this.selectedValue, name: this.selectedNameValue }
      this.inputTarget.value = country.name
    }
  }

  toggleDropdown () {
    const isVisible = this.dropdownTarget.classList.contains('country-select__dropdown--visible')

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

    this.dropdownTarget.classList.add('country-select__dropdown--visible')
    this.inputTarget.focus()
  }

  hideDropdown () {
    this.dropdownTarget.classList.remove('country-select__dropdown--visible')
  }

  filter (event) {
    const query = event.target.value.toLowerCase()

    this.filteredCountries = this.countries.filter(country => {
      return country.name.toLowerCase().includes(query) ||
             country.code.toLowerCase().startsWith(query)
    })

    this.renderOptions()
    this.showDropdown()
  }

  selectCountry (event) {
    const code = event.currentTarget.dataset.code
    const name = event.currentTarget.dataset.name

    this.inputTarget.value = name
    this.hiddenFieldTarget.value = code
    this.hideDropdown()

    // Trigger change event for form validation
    this.hiddenFieldTarget.dispatchEvent(new Event('change', { bubbles: true }))
  }

  clearSelection () {
    this.inputTarget.value = ''
    this.hiddenFieldTarget.value = ''
    this.filteredCountries = [...this.countries]
    this.renderOptions()
    this.inputTarget.focus()
  }

  renderOptions () {
    this.dropdownTarget.innerHTML = ''

    if (this.filteredCountries.length === 0) {
      const noResults = document.createElement('div')
      noResults.className = 'country-select__no-results'
      noResults.textContent = this.noCountriesLabelValue || 'No countries found'
      this.dropdownTarget.appendChild(noResults)
      return
    }

    this.filteredCountries.forEach(country => {
      const option = document.createElement('div')
      option.className = 'country-select__option'
      option.dataset.code = country.code
      option.dataset.name = country.name
      option.dataset.action = 'click->country-select#selectCountry'

      option.innerHTML = `
        <span class="country-select__option-name">${country.name}</span>
        <span class="country-select__option-code">${country.code}</span>
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
      const highlighted = this.dropdownTarget.querySelector('.country-select__option--highlighted')
      if (highlighted) {
        highlighted.click()
      }
    }
  }

  navigateOptions (direction) {
    const options = this.dropdownTarget.querySelectorAll('.country-select__option')
    const highlighted = this.dropdownTarget.querySelector('.country-select__option--highlighted')

    let newIndex = 0

    if (highlighted) {
      const currentIndex = Array.from(options).indexOf(highlighted)
      newIndex = currentIndex + direction
      highlighted.classList.remove('country-select__option--highlighted')
    }

    // Wrap around
    if (newIndex < 0) newIndex = options.length - 1
    if (newIndex >= options.length) newIndex = 0

    if (options[newIndex]) {
      options[newIndex].classList.add('country-select__option--highlighted')
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
    this.setupInitialValue()
    document.addEventListener('click', this.windowClick.bind(this))
  }

  disconnect () {
    document.removeEventListener('click', this.windowClick.bind(this))
  }
}
