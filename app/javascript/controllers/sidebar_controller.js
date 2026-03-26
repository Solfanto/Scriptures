import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["sidebar", "overlay", "label"]

  #expanded = true

  toggle() {
    this.#expanded = !this.#expanded

    if (window.innerWidth < 768) {
      this.#applyMobile()
    } else {
      this.#applyDesktop()
    }
  }

  #applyMobile() {
    const sidebar = this.sidebarTarget
    sidebar.style.removeProperty("width")

    if (this.#expanded) {
      sidebar.classList.remove("-translate-x-full")
      sidebar.classList.add("translate-x-0")
      this.overlayTarget.style.removeProperty("display")
    } else {
      sidebar.classList.add("-translate-x-full")
      sidebar.classList.remove("translate-x-0")
      this.overlayTarget.style.display = "none"
    }
  }

  #applyDesktop() {
    const sidebar = this.sidebarTarget
    sidebar.style.width = this.#expanded ? "16rem" : "5rem"

    this.labelTargets.forEach((el) => {
      el.style.display = this.#expanded ? "" : "none"
    })
  }
}
