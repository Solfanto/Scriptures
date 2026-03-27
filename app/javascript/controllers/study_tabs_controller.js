import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["tab", "panel"]

  switch(event) {
    const index = parseInt(event.params.index, 10)

    this.tabTargets.forEach((tab, i) => {
      tab.classList.toggle("bg-stone-100", i === index)
      tab.classList.toggle("dark:bg-stone-900", i === index)
      tab.classList.toggle("text-stone-900", i === index)
      tab.classList.toggle("dark:text-stone-100", i === index)
      tab.classList.toggle("text-stone-400", i !== index)
    })

    this.panelTargets.forEach((panel, i) => {
      panel.style.display = i === index ? "block" : "none"
    })
  }
}
