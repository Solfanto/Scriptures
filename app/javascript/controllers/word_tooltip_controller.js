import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  #tooltip = null

  show(event) {
    const word = event.currentTarget.dataset.word
    if (!word) return

    this.hide()

    const tooltip = document.createElement("div")
    tooltip.className = "word-tooltip fixed z-50 p-4 w-64 text-sm shadow-xl rounded-lg border bg-white dark:bg-stone-900 border-stone-200 dark:border-stone-700"
    tooltip.innerHTML = `
      <div class="flex justify-between items-start mb-2">
        <span class="text-xl font-serif rtl">${this.#escapeHTML(word)}</span>
        <span class="px-2 py-0.5 rounded-full text-[10px] font-semibold uppercase tracking-wider bg-stone-100 text-stone-800 dark:bg-stone-800 dark:text-stone-300">Word</span>
      </div>
      <p class="text-xs text-stone-500 italic">Click for word study (coming soon)</p>
    `

    document.body.appendChild(tooltip)

    const rect = event.currentTarget.getBoundingClientRect()
    const tooltipRect = tooltip.getBoundingClientRect()
    let top = rect.bottom + 8
    let left = rect.left + (rect.width / 2) - (tooltipRect.width / 2)

    // Keep within viewport
    left = Math.max(8, Math.min(left, window.innerWidth - tooltipRect.width - 8))
    if (top + tooltipRect.height > window.innerHeight - 8) {
      top = rect.top - tooltipRect.height - 8
    }

    tooltip.style.top = `${top}px`
    tooltip.style.left = `${left}px`

    this.#tooltip = tooltip
  }

  hide() {
    if (this.#tooltip) {
      this.#tooltip.remove()
      this.#tooltip = null
    }
  }

  disconnect() {
    this.hide()
  }

  #escapeHTML(str) {
    const div = document.createElement("div")
    div.textContent = str
    return div.innerHTML
  }
}
