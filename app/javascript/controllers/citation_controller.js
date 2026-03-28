import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    scripture: String,
    chapter: Number,
    verse: Number,
    corpus: String,
    translation: String,
    text: String
  }

  static targets = ["menu", "feedback"]

  toggle() {
    this.menuTarget.style.display = this.menuTarget.style.display === "none" ? "block" : "none"
  }

  close() {
    this.menuTarget.style.display = "none"
  }

  copyPlain() {
    const ref = `${this.scriptureValue} ${this.chapterValue}:${this.verseValue}`
    const text = `${this.textValue}\n— ${ref} (${this.translationValue})`
    this.#copy(text)
  }

  copyMLA() {
    const ref = `${this.scriptureValue} ${this.chapterValue}:${this.verseValue}`
    const text = `"${this.textValue}" (${ref}, ${this.translationValue}).`
    this.#copy(text)
  }

  copyChicago() {
    const ref = `${this.scriptureValue} ${this.chapterValue}:${this.verseValue}`
    const text = `${ref} (${this.translationValue}).`
    this.#copy(text)
  }

  copyTurabian() {
    const ref = `${this.scriptureValue} ${this.chapterValue}:${this.verseValue}`
    const text = `${ref} ${this.translationValue}.`
    this.#copy(text)
  }

  copyMarkdown() {
    const ref = `${this.scriptureValue} ${this.chapterValue}:${this.verseValue}`
    const text = `> ${this.textValue}\n>\n> — *${ref}* (${this.translationValue})`
    this.#copy(text)
  }

  copyHTML() {
    const ref = `${this.scriptureValue} ${this.chapterValue}:${this.verseValue}`
    const text = `<blockquote>\n  <p>${this.textValue}</p>\n  <cite>${ref} (${this.translationValue})</cite>\n</blockquote>`
    this.#copy(text)
  }

  #copy(text) {
    navigator.clipboard.writeText(text).then(() => {
      this.#showFeedback()
      this.close()
    })
  }

  #showFeedback() {
    this.feedbackTarget.style.display = "inline"
    setTimeout(() => {
      this.feedbackTarget.style.display = "none"
    }, 1500)
  }
}
