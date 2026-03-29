import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { text: String, lang: String }

  #utterance = null

  speak() {
    if (speechSynthesis.speaking) {
      speechSynthesis.cancel()
      return
    }

    this.#utterance = new SpeechSynthesisUtterance(this.textValue)
    this.#utterance.lang = this.#mapLang(this.langValue)
    this.#utterance.rate = 0.9
    speechSynthesis.speak(this.#utterance)
  }

  disconnect() {
    speechSynthesis.cancel()
  }

  #mapLang(lang) {
    const map = {
      "Hebrew": "he-IL",
      "Greek": "el-GR",
      "Arabic": "ar-SA",
      "Pali": "pi",
      "Sanskrit": "sa",
      "English": "en-US"
    }
    return map[lang] || "en-US"
  }
}
