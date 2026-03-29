import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['associationList']
  static values = {
    model: String,
    class: String,
    field: String,
    selectedRecordIds: Array,
    associationType: String, // "many", "one", or "belongs_to"
    newRecordUrl: String,
    selectLabel: String,
    addSelectedLabel: String,
    cancelLabel: String,
    searchPlaceholderLabel: String,
    noRecordsFoundLabel: String,
    createNewLabel: String,
    noAssociationsLabel: String
  }

  connect () {
    this.selectedRecordIds = this.selectedRecordIdsValue.map(id => String(id)) || []
    this.setupModal()
  }

  getActionButtonText () {
    switch (this.associationTypeValue) {
      case 'belongs_to':
      case 'one':
        return this.selectLabelValue || 'Select'
      case 'many':
      default:
        return this.addSelectedLabelValue || 'Add Selected'
    }
  }

  isSingleSelection () {
    return this.associationTypeValue === 'belongs_to' || this.associationTypeValue === 'one'
  }

  setupModal () {
    // Create modal if it doesn't exist
    if (!this.modalTarget) {
      this.createModal()
    }
  }

  createModal () {
    const modal = document.createElement('div')
    modal.className = 'association-selector-modal'
    modal.innerHTML = `
      <div class="association-selector-modal__overlay" data-action="click->association-selector#hideModal">
        <div class="association-selector-modal__content" data-action="click->association-selector#stopPropagation">
          <div class="association-selector-modal__header">
            <h3 class="association-selector-modal__title">${this.selectLabelValue || `Select ${this.classValue}`}</h3>
            <button type="button" class="association-selector-modal__close" data-action="click->association-selector#hideModal">
              <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"/>
              </svg>
            </button>
          </div>
          <div class="association-selector-modal__body">
            <div class="association-selector-modal__search">
              <input type="text"
                     placeholder="${this.searchPlaceholderLabelValue || `Search ${this.classValue.toLowerCase()}...`}"
                     class="association-selector-modal__search-input"
                     data-association-selector-target="searchInput"
                     data-action="input->association-selector#searchRecords">
            </div>
            <div class="association-selector-modal__records" data-association-selector-target="recordOptions">
              <!-- Records will be loaded here -->
            </div>
          </div>
          <div class="association-selector-modal__footer">
            <button type="button" class="btn btn--secondary" data-action="click->association-selector#hideModal">${this.cancelLabelValue || 'Cancel'}</button>
            <button type="button" class="btn btn--primary" data-action="click->association-selector#addSelectedRecords">${this.getActionButtonText()}</button>
          </div>
        </div>
      </div>
    `

    this.element.appendChild(modal)
    this.modal = modal
  }

  showModal () {
    this.loadRecords()
    this.modal.classList.add('association-selector-modal--visible')
  }

  hideModal () {
    this.modal.classList.remove('association-selector-modal--visible')
  }

  stopPropagation (event) {
    event.stopPropagation()
  }

  async loadRecords () {
    try {
      const snakeCaseClass = this.camelToSnakeCase(this.classValue)
      const response = await fetch(`/admin/${snakeCaseClass}s.json`)
      const data = await response.json()
      this.renderRecords(data[snakeCaseClass + 's'] || [])
    } catch (error) {
      console.error(`Failed to load ${this.camelToSnakeCase(this.classValue)}s:`, error)
      this.renderRecords([])
    }
  }

  camelToSnakeCase (str) {
    return str.replace(/[A-Z]/g, letter => `_${letter.toLowerCase()}`).replace(/^_/, '')
  }

  renderRecords (records) {
    const recordOptions = this.modal.querySelector('[data-association-selector-target="recordOptions"]')
    recordOptions.innerHTML = ''

    if (records.length === 0) {
      const emptyContent = `
        <div class="association-selector-modal__empty">
          <div class="association-selector-modal__empty-message">${this.noRecordsFoundLabelValue || `No ${this.classValue.toLowerCase()}s found`}</div>
          ${this.newRecordUrlValue
? `
            <div class="association-selector-modal__empty-actions">
              <a href="${this.newRecordUrlValue}" class="btn btn--primary btn--small" data-turbo-frame="_top">
                ${this.createNewLabelValue || `Create new ${this.classValue.toLowerCase()}`}
              </a>
            </div>
          `
: ''}
        </div>
      `
      recordOptions.innerHTML = emptyContent
      return
    }

    const inputType = this.isSingleSelection() ? 'radio' : 'checkbox'
    const inputName = this.isSingleSelection() ? `association_${this.fieldValue}` : ''

    records.forEach(record => {
      const isSelected = this.selectedRecordIds.includes(String(record.id))
      const recordElement = document.createElement('label')
      recordElement.className = `association-selector-modal__record ${isSelected ? 'association-selector-modal__record--selected' : ''}`
      recordElement.htmlFor = `${this.fieldValue}-${record.id}`
      recordElement.dataset.recordId = record.id
      recordElement.dataset.recordDisplayName = this.getRecordDisplayName(record)

      recordElement.innerHTML = `
        <div class="association-selector-modal__record-checkbox">
          <input id="${this.fieldValue}-${record.id}" type="${inputType}" ${isSelected ? 'checked' : ''} data-record-id="${record.id}" data-display-name="${this.getRecordDisplayName(record)}" ${inputName ? `name="${inputName}"` : ''}>
        </div>
        <div class="association-selector-modal__record-info">
          <div class="association-selector-modal__record-name">${this.getRecordDisplayName(record)}</div>
          <div class="association-selector-modal__record-details">${this.getRecordDetails(record)}</div>
        </div>
      `

      recordOptions.appendChild(recordElement)
    })
  }

  getRecordDisplayName (record) {
    return record.name || record.email || record.title || `${this.classValue} #${record.id}`
  }

  getRecordDetails (record) {
    const details = []
    if (record.admin !== undefined) details.push(record.admin ? 'Admin' : 'User')
    if (record.status) details.push(record.status)
    if (record.verified !== undefined) details.push(record.verified ? 'Verified' : 'Unverified')
    return details.join(' • ')
  }

  searchRecords (event) {
    const query = event.target.value.toLowerCase()
    const records = this.modal.querySelectorAll('.association-selector-modal__record')

    records.forEach(record => {
      const name = record.querySelector('.association-selector-modal__record-name').textContent.toLowerCase()
      const isVisible = name.includes(query)
      record.style.display = isVisible ? 'flex' : 'none'
    })
  }

  addSelectedRecords () {
    const inputs = this.modal.querySelectorAll('input[type="radio"]:checked, input[type="checkbox"]:checked')
    const selectedIds = Array.from(inputs).map(input => input.dataset.recordId)

    if (this.isSingleSelection()) {
      // For single selection, clear existing and add the new one
      this.clearAllRecords()
      if (inputs.length > 0) {
        this.selectedRecordIds = [inputs[0].dataset.recordId]
        this.addRecordToList(inputs[0])
      }
    } else {
      // Multiple selection logic - sync with modal state
      const currentIds = [...this.selectedRecordIds]

      // Add newly selected records
      selectedIds.forEach(recordId => {
        if (!this.selectedRecordIds.includes(recordId)) {
          this.selectedRecordIds.push(recordId)
          const input = this.modal.querySelector(`input[data-record-id="${recordId}"]`)
          this.addRecordToList(input)
        }
      })

      // Remove unselected records
      currentIds.forEach(recordId => {
        if (!selectedIds.includes(recordId)) {
          this.removeRecordFromList(recordId)
        }
      })
    }

    this.hideModal()
  }

  clearAllRecords () {
    const associationList = this.associationListTarget
    associationList.innerHTML = ''

    // Remove all hidden fields for this association
    const form = this.element.closest('form')
    const suffix = this.isSingleSelection() ? '' : '[]'
    const hiddenFields = form.querySelectorAll(`input[name="${this.modelValue.toLowerCase()}[${this.fieldValue}]${suffix}"]`)
    hiddenFields.forEach(field => field.remove())
  }

  addRecordToList (record) {
    const associationList = this.associationListTarget

    // Check if record is already in the list to prevent duplicates
    const existingRecord = associationList.querySelector(`[data-record-id="${record.dataset.recordId}"]`)
    if (existingRecord) {
      return // Record already exists, don't add it again
    }

    const emptyMessage = associationList.querySelector('.record-edit__field-association-empty')
    if (emptyMessage) {
      emptyMessage.remove()
    }

    const recordItem = document.createElement('div')
    recordItem.className = 'record-edit__field-association-item'
    recordItem.dataset.recordId = record.dataset.recordId
    recordItem.innerHTML = `
      <span class="record-edit__field-association-name">${record.dataset.displayName}</span>
      <button type="button" class="record-edit__field-association-remove" data-action="click->association-selector#removeRecord" data-record-id="${record.dataset.recordId}">
        <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"/>
        </svg>
      </button>
    `

    associationList.appendChild(recordItem)

    // Add hidden field
    const form = this.element.closest('form')
    const hiddenField = document.createElement('input')
    hiddenField.type = 'hidden'
    const suffix = this.isSingleSelection() ? '' : '[]'
    hiddenField.name = `${this.modelValue.toLowerCase()}[${this.fieldValue}]${suffix}`
    hiddenField.value = record.dataset.recordId
    form.appendChild(hiddenField)
  }

  removeRecord (event) {
    const recordId = event.currentTarget.dataset.recordId
    this.removeRecordFromList(recordId)
  }

  removeRecordFromList (recordId) {
    const associationList = this.associationListTarget
    const recordItem = associationList.querySelector(`[data-record-id="${recordId}"]`)

    if (!recordItem) return

    // Remove from selected list
    this.selectedRecordIds = this.selectedRecordIds.filter(id => id !== recordId)

    // Remove from UI
    recordItem.remove()

    // Remove hidden field
    const form = this.element.closest('form')
    const suffix = this.isSingleSelection() ? '' : '[]'
    const hiddenField = form.querySelector(`input[name="${this.modelValue.toLowerCase()}[${this.fieldValue}]${suffix}"][value="${recordId}"]`)
    if (hiddenField) {
      hiddenField.remove()
    }

    // Show empty message if no records left
    if (associationList.children.length === 0) {
      const emptyMessage = document.createElement('div')
      emptyMessage.className = 'record-edit__field-association-empty'
      emptyMessage.textContent = this.noAssociationsLabelValue || `No ${this.classValue.toLowerCase()}s associated`
      associationList.appendChild(emptyMessage)
    }
  }
}
