import { Controller } from '@hotwired/stimulus'
import { Turbo } from '@hotwired/turbo-rails'
import { useThrottle } from 'stimulus-use'

export default class extends Controller {
  static throttles = ['handleDragOverThrottled']

  connect () {
    useThrottle(this, { wait: 100 }) // 10fps

    // Store bound handlers for proper cleanup
    this.boundDragEnter = this.handleDragEnter.bind(this)
    this.boundDragOver = this.handleDragOver.bind(this)
    this.boundDragEnd = this.handleDragEnd.bind(this)
    this.boundDrop = this.handleDrop.bind(this)

    // The controller is on the container, so this.element is the container
    // Initialize all existing drag handles
    this.initializeDragHandles()

    // Watch for new drag handles being added (for dynamically added rows)
    this.observer = new MutationObserver(() => {
      this.initializeDragHandles()
    })
    this.observer.observe(this.element, { childList: true, subtree: true })

    // Listen for drag events on draggable rows
    this.element.addEventListener('dragenter', this.boundDragEnter, true)
    this.element.addEventListener('dragover', this.boundDragOver, true)
    this.element.addEventListener('dragend', this.boundDragEnd, true)
    this.element.addEventListener('drop', this.boundDrop, true)

    this.csrfToken = document.querySelector('meta[name="csrf-token"]')?.content
  }

  initializeDragHandles () {
    // Store bound handler if not already stored
    if (!this.boundDragStart) {
      this.boundDragStart = this.handleDragStart.bind(this)
    }

    // Find all drag handles within the container and make them draggable
    this.element.querySelectorAll('[data-positions-drag-handle]').forEach(dragHandle => {
      // Only initialize if not already initialized
      if (!dragHandle.hasAttribute('data-positions-initialized')) {
        dragHandle.setAttribute('draggable', 'true')
        dragHandle.setAttribute('data-positions-initialized', 'true')
        dragHandle.addEventListener('dragstart', this.boundDragStart)
      }
    })
  }

  disconnect () {
    if (this.observer) {
      this.observer.disconnect()
    }
    if (this.boundDragStart) {
      this.element.querySelectorAll('[data-positions-drag-handle]').forEach(dragHandle => {
        dragHandle.removeEventListener('dragstart', this.boundDragStart)
        dragHandle.removeAttribute('data-positions-initialized')
      })
    }
    if (this.boundDragEnter) {
      this.element.removeEventListener('dragenter', this.boundDragEnter, true)
    }
    if (this.boundDragOver) {
      this.element.removeEventListener('dragover', this.boundDragOver, true)
    }
    if (this.boundDragEnd) {
      this.element.removeEventListener('dragend', this.boundDragEnd, true)
    }
    if (this.boundDrop) {
      this.element.removeEventListener('drop', this.boundDrop, true)
    }
  }

  handleDragStart (event) {
    // Find the row element from the drag handle
    const dragHandle = event.target.closest('[data-positions-drag-handle]')
    const rowElement = dragHandle?.closest('[data-positions-draggable]')

    if (!rowElement) return

    this.draggedElement = rowElement
    event.dataTransfer.effectAllowed = 'move'
    // Store minimal data - we don't need the full HTML
    event.dataTransfer.setData('text/plain', '')
    rowElement.classList.add('dragging')

    // Store original position to detect if element actually moved
    const elements = Array.from(this.element.querySelectorAll('[data-positions-draggable]'))
    this.originalIndex = elements.indexOf(rowElement)

    // Store the record ID in data transfer for reference
    const recordId = this.getRecordId(rowElement)
    if (recordId) {
      event.dataTransfer.setData('record-id', recordId)
    }
  }

  handleDragEnter (event) {
    event.preventDefault()

    const rowElement = event.target.closest('[data-positions-draggable]')
    if (!rowElement || rowElement.classList.contains('dragging')) {
      return
    }

    // Move immediately when entering a row for more responsive feel
    const dragging = this.element.querySelector('.dragging')
    if (!dragging || dragging === rowElement) {
      return
    }

    // Determine direction: if dragged element is below the row we're entering, we're going up
    const elements = Array.from(this.element.querySelectorAll('[data-positions-draggable]'))
    const rowIndex = elements.indexOf(rowElement)
    const dragIndex = elements.indexOf(dragging)
    const isDraggingUp = dragIndex > rowIndex

    // Only move if not already in the correct position
    if (isDraggingUp) {
      // Dragging up: move before the row we're entering
      if (dragging !== rowElement && dragging.nextElementSibling !== rowElement) {
        this.element.insertBefore(dragging, rowElement)
        const recordId = this.getRecordId(rowElement)
        if (recordId) {
          dragging.dataset.dropTargetId = recordId
          dragging.dataset.dropPlacement = 'before'
        }
      }
    } else {
      // Dragging down: move after the row we're entering
      if (dragIndex !== rowIndex + 1) {
        const nextSibling = rowElement.nextElementSibling
        if (nextSibling) {
          this.element.insertBefore(dragging, nextSibling)
        } else {
          this.element.appendChild(dragging)
        }
        const recordId = this.getRecordId(rowElement)
        if (recordId) {
          dragging.dataset.dropTargetId = recordId
          dragging.dataset.dropPlacement = 'after'
        }
      }
    }
  }

  handleDragOver (event) {
    // Always prevent default on the container to allow drop event to fire
    // This must happen on every dragover event, regardless of target
    event.preventDefault()
    event.dataTransfer.dropEffect = 'move'

    // Only handle dragover logic on draggable rows, not the container itself
    const rowElement = event.target.closest('[data-positions-draggable]')
    if (!rowElement || rowElement.classList.contains('dragging')) {
      return
    }

    // The rest of the logic is throttled
    this.handleDragOverThrottled(event)
  }

  handleDragOverThrottled (event) {
    const dragging = this.element.querySelector('.dragging')
    if (!dragging) return

    const afterElement = this.getDragAfterElement(event.clientY, this.element)

    // Only move if the position actually changed
    if (afterElement == null) {
      // Moving to end - check if not already last
      const elements = Array.from(this.element.querySelectorAll('[data-positions-draggable]'))
      const isLast = elements.indexOf(dragging) === elements.length - 1

      if (!isLast) {
        this.element.appendChild(dragging)
        // Store the target for drop
        const updatedElements = Array.from(this.element.querySelectorAll('[data-positions-draggable]'))
        const draggedIndex = updatedElements.indexOf(dragging)
        const previousElement = draggedIndex > 0 ? updatedElements[draggedIndex - 1] : null
        if (previousElement) {
          const recordId = this.getRecordId(previousElement)
          if (recordId) {
            dragging.dataset.dropTargetId = recordId
            dragging.dataset.dropPlacement = 'after'
          }
        }
      }
    } else {
      // Moving before an element - check if not already in that position
      if (dragging !== afterElement && dragging.nextElementSibling !== afterElement) {
        this.element.insertBefore(dragging, afterElement)
        // Store the target for drop
        const recordId = this.getRecordId(afterElement)
        if (recordId) {
          dragging.dataset.dropTargetId = recordId
          dragging.dataset.dropPlacement = 'before'
        }
      }
    }
  }

  handleDrop (event) {
    // Prevent default to avoid browser reverting DOM changes
    event.preventDefault()

    const draggedElement = this.element.querySelector('.dragging')
    if (!draggedElement) {
      this.cleanupDrag()
      return
    }

    // Mark that we're processing a drop to prevent handleDragEnd from interfering
    this.isProcessingDrop = true

    // Use the stored target from dragover (before browser potentially reverts)
    const targetRecordId = draggedElement.dataset.dropTargetId
    const placement = draggedElement.dataset.dropPlacement
    const draggedRecordId = this.getRecordId(draggedElement)

    // Clean up the temporary data attributes
    delete draggedElement.dataset.dropTargetId
    delete draggedElement.dataset.dropPlacement

    if (!targetRecordId || !placement) {
      this.isProcessingDrop = false
      this.cleanupDrag()
      return
    }

    // Update position via API - cleanup will happen in updatePosition's finally block
    this.updatePosition(draggedRecordId, targetRecordId, placement).finally(() => {
      this.isProcessingDrop = false
    })
  }

  handleDragEnd (event) {
    // dragend always fires, even if drag was cancelled or dropped outside
    // Use this only for cleanup as a safety net if drop wasn't processed
    // The actual position update should happen in handleDrop (which only fires on successful drops)
    if (!this.isProcessingDrop) {
      this.cleanupDrag()
    }
  }

  cleanupDrag () {
    const dragging = this.element.querySelector('.dragging')
    if (dragging) {
      dragging.classList.remove('dragging')
    }
    this.originalIndex = undefined
    this.draggedElement = undefined
  }

  getRecordId (element) {
    // Get record ID from data-record-id attribute
    return element?.dataset?.recordId || null
  }

  getDragAfterElement (y, container) {
    const draggableElements = [...container.querySelectorAll('[data-positions-draggable]:not(.dragging)')]

    return draggableElements.reduce((closest, child) => {
      const box = child.getBoundingClientRect()
      const offset = y - box.top - box.height / 2

      if (offset < 0 && offset > closest.offset) {
        return { offset: offset, element: child }
      } else {
        return closest
      }
    }, { offset: Number.NEGATIVE_INFINITY }).element
  }

  async updatePosition (recordId, targetRecordId, placement) {
    const url = this.buildUpdateUrl(recordId)

    try {
      const response = await fetch(url, {
        method: 'PATCH',
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-CSRF-Token': this.csrfToken
        },
        body: JSON.stringify({
          target_record_id: targetRecordId,
          placement: placement
        })
      })

      if (!response.ok) {
        console.error('Failed to update position:', response.statusText)
      }
    } catch (error) {
      console.error('Error updating position:', error)
    } finally {
      // Always cleanup and refresh, regardless of success or failure
      this.cleanupDrag()

      // Check if we're in a turbo frame context before trying to refresh
      const recordsFrame = document.querySelector('turbo-frame#records')
      if (recordsFrame) {
        Turbo.visit(window.location.href, { action: "replace", frame: "records" })
      } else {
        // Fallback to full page refresh if no turbo frame
        Turbo.visit(window.location.href)
      }
    }
  }

  buildUpdateUrl (recordId) {
    // Check if we're in a CMS records context (nested route)
    const categoryId = this.element.dataset.cmsRecordFormCategoryIdValue ||
                      this.element.closest('[data-cms-record-form-category-id-value]')?.dataset.cmsRecordFormCategoryIdValue

    if (categoryId) {
      // CMS records use nested routes: /admin/cms_record_categories/:category_id/cms_records/:id/update_position
      return `/admin/cms_record_categories/${categoryId}/cms_records/${recordId}/update_position`
    }

    // For regular table rows, build URL from current path
    const pathParts = window.location.pathname.split('/')
    const controllerIndex = pathParts.indexOf('admin') + 1
    const controller = pathParts[controllerIndex]

    return `/admin/${controller}/${recordId}/update_position`
  }
}
