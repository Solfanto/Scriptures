import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['table', 'tbody', 'row', 'jsonInput']
  static values = { fieldName: String }

  connect () {
    this.updateRowStates()
    this.updateJsonInput()
  }

  onKeyInput (event) {
    this.updateRowStates()
    this.updateJsonInput()
  }

  onValueInput (event) {
    this.updateRowStates()
    this.updateJsonInput()
  }

  removeRow (event) {
    const row = event.target.closest('[data-jsonb-editor-target="row"]')
    if (row) {
      row.remove()
      this.updateRowStates()
      this.updateJsonInput()
    }
  }

  updateRowStates () {
    const rows = this.tbodyTarget.querySelectorAll('[data-jsonb-editor-target="row"]')

    rows.forEach((row, index) => {
      const keyInput = row.querySelector('.jsonb-key-input')
      const valueInput = row.querySelector('.jsonb-value-input')
      const removeBtn = row.querySelector('.record-edit__field-jsonb-remove-btn')

      const hasKey = keyInput && keyInput.value.trim() !== ''
      const hasValue = valueInput && valueInput.value.trim() !== ''
      const isLastRow = index === rows.length - 1

      // Show/hide remove button based on whether row has content and is not the last row
      if (removeBtn) {
        removeBtn.style.display = (hasKey || hasValue) && !isLastRow ? 'inline-flex' : 'none'
      }

      // Add new empty row if the last row has a key filled
      if (isLastRow && hasKey) {
        this.addEmptyRow()
      }
    })
  }

  addEmptyRow () {
    const lastRow = this.tbodyTarget.querySelector('[data-jsonb-editor-target="row"]:last-child')
    if (!lastRow) return

    const newRow = lastRow.cloneNode(true)

    // Clear the inputs in the new row
    const keyInput = newRow.querySelector('.jsonb-key-input')
    const valueInput = newRow.querySelector('.jsonb-value-input')

    if (keyInput) {
      keyInput.value = ''
      keyInput.placeholder = 'Enter key...'
    }
    if (valueInput) {
      valueInput.value = ''
      valueInput.placeholder = 'Enter value...'
    }

    this.tbodyTarget.appendChild(newRow)
    this.updateRowStates()
    this.updateJsonInput()
  }

  updateJsonInput () {
    const rows = this.tbodyTarget.querySelectorAll('[data-jsonb-editor-target="row"]')
    const jsonData = {}

    rows.forEach(row => {
      const keyInput = row.querySelector('.jsonb-key-input')
      const valueInput = row.querySelector('.jsonb-value-input')

      if (keyInput && keyInput.value.trim() !== '') {
        // Check if this is a filtered field
        const isFiltered = valueInput && valueInput.dataset.filtered === 'true'

        if (isFiltered && valueInput.value === '******') {
          // For filtered fields showing "******", preserve the original value
          // We'll need to get this from the initial data
          const originalValue = this.getOriginalValue(keyInput.value.trim())
          jsonData[keyInput.value.trim()] = originalValue || ''
        } else {
          jsonData[keyInput.value.trim()] = valueInput ? valueInput.value.trim() : ''
        }
      }
    })

    // Update the hidden field with JSON string
    this.jsonInputTarget.value = JSON.stringify(jsonData)
  }

  getOriginalValue (key) {
    // Get the original value from the initial JSON data
    try {
      const initialData = JSON.parse(this.jsonInputTarget.dataset.initialValue || '{}')
      return initialData[key]
    } catch (e) {
      return null
    }
  }
}
