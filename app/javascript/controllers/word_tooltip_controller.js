import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  #tooltip = null

  show(event) {
    const word = event.currentTarget.dataset.word
    const passageId = event.currentTarget.dataset.passageId
    const position = event.currentTarget.dataset.position
    if (!word) return

    this.hide()

    const tooltip = document.createElement("div")
    tooltip.className = "word-tooltip fixed z-50 p-4 w-72 text-sm shadow-xl rounded-lg border bg-white dark:bg-stone-900 border-stone-200 dark:border-stone-700"
    tooltip.innerHTML = `
      <div class="flex justify-between items-start mb-2">
        <span class="text-xl font-serif rtl">${this.#escapeHTML(word)}</span>
        <span class="px-2 py-0.5 rounded-full text-[10px] font-semibold uppercase tracking-wider bg-stone-100 text-stone-800 dark:bg-stone-800 dark:text-stone-300">Word</span>
      </div>
      <p class="text-xs text-stone-400" id="word-tooltip-content">Loading...</p>
    `

    document.body.appendChild(tooltip)
    this.#position(tooltip, event.currentTarget)
    this.#tooltip = tooltip

    if (passageId && position) {
      this.#fetchWordData(passageId, position)
    }
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

  async #fetchWordData(passageId, position) {
    try {
      const response = await fetch(`/word_study/${passageId}/${position}`)
      const data = await response.json()
      const content = this.#tooltip?.querySelector("#word-tooltip-content")
      if (!content) return

      if (data.definition) {
        content.innerHTML = `
          <div class="space-y-1.5">
            ${data.transliteration ? `<div class="text-xs"><span class="text-stone-400">Transliteration:</span> <span class="font-medium">${this.#escapeHTML(data.transliteration)}</span></div>` : ""}
            ${data.lemma ? `<div class="text-xs"><span class="text-stone-400">Lemma:</span> <span class="font-medium font-serif">${this.#escapeHTML(data.lemma)}</span></div>` : ""}
            ${data.morphology ? `<div class="text-xs"><span class="text-stone-400">Morphology:</span> <span class="font-mono">${this.#escapeHTML(data.morphology)}</span></div>` : ""}
            <div class="text-xs text-stone-600 dark:text-stone-400 pt-1 border-t border-stone-100 dark:border-stone-800">${this.#escapeHTML(data.definition.substring(0, 150))}</div>
            ${data.strongs_number ? `<div class="text-[10px] text-stone-400">${this.#escapeHTML(data.strongs_number)} · ${data.concordance_count} occurrences</div>` : ""}
          </div>
        `
      } else {
        content.textContent = data.message || "No lexicon data available"
      }
    } catch {
      const content = this.#tooltip?.querySelector("#word-tooltip-content")
      if (content) content.textContent = "No lexicon data available"
    }
  }

  #position(tooltip, target) {
    const rect = target.getBoundingClientRect()
    const tooltipRect = tooltip.getBoundingClientRect()
    let top = rect.bottom + 8
    let left = rect.left + (rect.width / 2) - (tooltipRect.width / 2)

    left = Math.max(8, Math.min(left, window.innerWidth - tooltipRect.width - 8))
    if (top + tooltipRect.height > window.innerHeight - 8) {
      top = rect.top - tooltipRect.height - 8
    }

    tooltip.style.top = `${top}px`
    tooltip.style.left = `${left}px`
  }

  #escapeHTML(str) {
    const div = document.createElement("div")
    div.textContent = str
    return div.innerHTML
  }
}
