import { Controller } from '@hotwired/stimulus'
import { Turbo } from '@hotwired/turbo-rails'
import { useDebounce } from 'stimulus-use'

export default class extends Controller {
  static targets = ['bulkActions', 'discardCount', 'restoreCount', 'deleteCount', 'filterInput', 'columnsMenu']
  static values = {
    resourceName: String,
    discardable: Boolean,
    confirmDiscardLabel: String,
    confirmDeleteLabel: String,
    confirmRestoreLabel: String,
    errorLabel: String
  }

  static debounces = ['filter']

  #boundCloseColumnsMenu = null

  connect () {
    useDebounce(this, { wait: 500 })
    this.updateBulkActions()
    this.#applyHiddenColumns()
    this.#boundCloseColumnsMenu = this.#closeColumnsMenuOnClickOutside.bind(this)
    document.addEventListener('click', this.#boundCloseColumnsMenu)
  }

  disconnect () {
    document.removeEventListener('click', this.#boundCloseColumnsMenu)
  }

  toggleSelectAll (event) {
    const isChecked = event.target.checked
    const checkboxes = this.element.querySelectorAll('.records__row-select')

    checkboxes.forEach(checkbox => {
      checkbox.checked = isChecked
    })

    this.updateBulkActions()
  }

  updateSelection () {
    this.updateBulkActions()
  }

  updateBulkActions () {
    if (!this.hasBulkActionsTarget) return

    const checkboxes = this.element.querySelectorAll('.records__row-select:checked')
    const selectedCount = checkboxes.length

    if (selectedCount === 0) {
      this.bulkActionsTarget.style.display = 'none'
      return
    }

    this.bulkActionsTarget.style.display = 'block'

    // Count discarded vs non-discarded selected items
    let discardedCount = 0
    let nonDiscardedCount = 0

    checkboxes.forEach(checkbox => {
      const row = checkbox.closest('.records__data-row')
      if (row.classList.contains('records__data-row--discarded')) {
        discardedCount++
      } else {
        nonDiscardedCount++
      }
    })

    if (this.discardableValue) {
      // Show discard button if there are non-discarded items
      const discardButton = this.element.querySelector('.records__bulk-discard')
      if (discardButton) {
        if (nonDiscardedCount > 0 && this.hasDiscardCountTarget) {
          discardButton.style.display = 'inline-block'
          this.discardCountTarget.textContent = nonDiscardedCount
        } else {
          discardButton.style.display = 'none'
        }
      }

      // Show restore button if there are discarded items
      const restoreButton = this.element.querySelector('.records__bulk-restore')
      if (restoreButton) {
        if (discardedCount > 0 && this.hasRestoreCountTarget) {
          restoreButton.style.display = 'inline-block'
          this.restoreCountTarget.textContent = discardedCount
        } else {
          restoreButton.style.display = 'none'
        }
      }

      // Show delete button if there are discarded items
      const deleteButton = this.element.querySelector('.records__bulk-delete')
      if (deleteButton) {
        if (discardedCount > 0 && this.hasDeleteCountTarget) {
          deleteButton.style.display = 'inline-block'
          this.deleteCountTarget.textContent = discardedCount
        } else {
          deleteButton.style.display = 'none'
        }
      }
    } else {
      // Hide discard and restore buttons
      const discardButton = this.element.querySelector('.records__bulk-discard')
      const restoreButton = this.element.querySelector('.records__bulk-restore')
      if (discardButton) {
        discardButton.style.display = 'none'
      }
      if (restoreButton) {
        restoreButton.style.display = 'none'
      }

      // Show delete button for all selected items
      const deleteButton = this.element.querySelector('.records__bulk-delete')
      if (deleteButton) {
        if (selectedCount > 0 && this.hasDeleteCountTarget) {
          deleteButton.style.display = 'inline-block'
          this.deleteCountTarget.textContent = selectedCount
        } else {
          deleteButton.style.display = 'none'
        }
      }
    }
  }

  bulkDiscard () {
    const nonDiscardedIds = this.#getNonDiscardedSelectedIds()

    if (nonDiscardedIds.length === 0) return

    const message = this.confirmDiscardLabelValue.replace('%{count}', nonDiscardedIds.length)
    if (confirm(message)) {
      this.#performBulkAction('discard', nonDiscardedIds)
    }
  }

  bulkDelete () {
    let idsToDelete = []

    if (this.discardableValue) {
      // For discardable models, only delete discarded records
      idsToDelete = this.#getDiscardedSelectedIds()
    } else {
      // For non-discardable models, delete all selected records
      idsToDelete = this.#getSelectedIds()
    }

    if (idsToDelete.length === 0) return

    const message = this.confirmDeleteLabelValue.replace('%{count}', idsToDelete.length)
    if (confirm(message)) {
      this.#performBulkAction('delete', idsToDelete)
    }
  }

  bulkRestore () {
    const discardedIds = this.#getDiscardedSelectedIds()

    if (discardedIds.length === 0) return

    const message = this.confirmRestoreLabelValue.replace('%{count}', discardedIds.length)
    if (confirm(message)) {
      this.#performBulkAction('restore', discardedIds)
    }
  }

  // Column visibility

  toggleColumnsMenu (event) {
    event.stopPropagation()
    if (!this.hasColumnsMenuTarget) return
    const menu = this.columnsMenuTarget
    menu.style.display = menu.style.display === 'none' ? 'block' : 'none'
  }

  toggleColumn (event) {
    const key = event.target.dataset.columnKey
    const visible = event.target.checked
    const hiddenColumns = this.#getHiddenColumns()

    if (visible) {
      hiddenColumns.delete(key)
    } else {
      hiddenColumns.add(key)
    }

    this.#saveHiddenColumns(hiddenColumns)
    this.#setColumnVisibility(key, visible)
  }

  // Private

  #getSelectedIds () {
    const checkboxes = this.element.querySelectorAll('.records__row-select:checked')
    return Array.from(checkboxes).map(checkbox => checkbox.dataset.recordId)
  }

  #getNonDiscardedSelectedIds () {
    const checkboxes = this.element.querySelectorAll('.records__row-select:checked')
    return Array.from(checkboxes)
      .filter(checkbox => !checkbox.closest('.records__data-row').classList.contains('records__data-row--discarded'))
      .map(checkbox => checkbox.dataset.recordId)
  }

  #getDiscardedSelectedIds () {
    const checkboxes = this.element.querySelectorAll('.records__row-select:checked')
    return Array.from(checkboxes)
      .filter(checkbox => checkbox.closest('.records__data-row').classList.contains('records__data-row--discarded'))
      .map(checkbox => checkbox.dataset.recordId)
  }

  filter (event) {
    // Prevent the default form submission
    event.preventDefault()

    // Collect all filter values from all filter inputs
    const filterParams = {}

    this.filterInputTargets.forEach(input => {
      const name = input.name
      // Extract the filter key from name like "filter[column_name]"
      const match = name.match(/filter\[(.+)\]/)
      if (match) {
        filterParams[match[1]] = input.value.trim()
      }
    })

    // Build URL with current pathname
    const currentUrl = new URL(window.location.href)
    const newParams = new URLSearchParams()

    // Preserve existing query parameters (sort, limit, etc.) but reset page
    currentUrl.searchParams.forEach((value, key) => {
      if (key !== 'filter' && key !== 'page') {
        newParams.set(key, value)
      }
    })

    // Add all filter params
    Object.keys(filterParams).forEach(key => {
      newParams.append(`filter[${key}]`, filterParams[key])
    })

    // Navigate to the new URL with all filters (page will default to 1)
    const newUrl = `${currentUrl.pathname}?${newParams.toString()}`
    Turbo.visit(newUrl)
  }

  async #performBulkAction (action, ids) {
    try {
      const response = await fetch(`/admin/${this.resourceNameValue}/bulk_${action}`, {
        method: 'POST',
        headers: {
          Accept: 'text/vnd.turbo-stream.html',
          'Content-Type': 'application/json',
          'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]')?.content
        },
        body: JSON.stringify({ ids })
      })

      if (response.ok) {
        const html = await response.text()
        Turbo.renderStreamMessage(html)

        // Clear selections after successful action
        this.#clearSelections()
      } else {
        alert(this.errorLabelValue)
      }
    } catch (error) {
      console.error('Bulk action error:', error)
      alert(this.errorLabelValue)
    }
  }

  #clearSelections () {
    const checkboxes = this.element.querySelectorAll('.records__row-select:checked, .records__select-all:checked')
    checkboxes.forEach(checkbox => {
      checkbox.checked = false
    })
    this.updateBulkActions()
  }

  // Column visibility helpers

  #storageKey () {
    return `records_hidden_columns:${this.resourceNameValue}`
  }

  #getHiddenColumns () {
    try {
      const stored = localStorage.getItem(this.#storageKey())
      return stored ? new Set(JSON.parse(stored)) : new Set()
    } catch {
      return new Set()
    }
  }

  #saveHiddenColumns (hiddenColumns) {
    localStorage.setItem(this.#storageKey(), JSON.stringify([...hiddenColumns]))
  }

  #applyHiddenColumns () {
    const hiddenColumns = this.#getHiddenColumns()
    hiddenColumns.forEach(key => {
      this.#setColumnVisibility(key, false)
    })

    // Sync checkboxes in the columns menu
    if (this.hasColumnsMenuTarget) {
      this.columnsMenuTarget.querySelectorAll('input[data-column-key]').forEach(checkbox => {
        checkbox.checked = !hiddenColumns.has(checkbox.dataset.columnKey)
      })
    }
  }

  #setColumnVisibility (key, visible) {
    const cells = this.element.querySelectorAll(`td[data-column-key="${key}"], th[data-column-key="${key}"]`)
    cells.forEach(cell => {
      cell.style.display = visible ? '' : 'none'
    })
  }

  #closeColumnsMenuOnClickOutside (event) {
    if (!this.hasColumnsMenuTarget) return
    const toggle = this.element.querySelector('.records__columns-toggle')
    if (toggle && !toggle.contains(event.target)) {
      this.columnsMenuTarget.style.display = 'none'
    }
  }
}
