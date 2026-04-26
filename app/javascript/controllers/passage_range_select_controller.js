import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["checkbox", "rangeButton", "rangeForm", "selectionLabel"]

  #lastIndex = null

  toggle(event) {
    const target = event.target
    const index = this.checkboxTargets.indexOf(target)

    if (event.shiftKey && this.#lastIndex !== null && this.#lastIndex !== index) {
      const [from, to] = [this.#lastIndex, index].sort((a, b) => a - b)
      for (let i = from; i <= to; i++) {
        this.checkboxTargets[i].checked = target.checked
      }
    }

    this.#lastIndex = index
    this.#sync()
  }

  #sync() {
    const selected = this.checkboxTargets.filter((c) => c.checked)
    const count = selected.length

    this.#syncHiddenInputs(selected)

    if (this.hasRangeButtonTarget) {
      this.rangeButtonTarget.disabled = count === 0
    }

    if (this.hasSelectionLabelTarget) {
      if (count === 0) {
        this.selectionLabelTarget.classList.add("hidden")
      } else {
        this.selectionLabelTarget.textContent = `${count} selected`
        this.selectionLabelTarget.classList.remove("hidden")
      }
    }
  }

  #syncHiddenInputs(selected) {
    if (!this.hasRangeFormTarget) return

    this.rangeFormTarget.querySelectorAll('input[name="passage_ids[]"]').forEach((el) => el.remove())

    selected.forEach((checkbox) => {
      const input = document.createElement("input")
      input.type = "hidden"
      input.name = "passage_ids[]"
      input.value = checkbox.value
      this.rangeFormTarget.appendChild(input)
    })
  }
}
