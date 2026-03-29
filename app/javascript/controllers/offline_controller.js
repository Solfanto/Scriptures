import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { corpus: String, translation: String }
  static targets = ["status"]

  async download() {
    this.statusTarget.textContent = "Downloading..."

    try {
      const response = await fetch(`/export/${this.corpusValue}/${this.translationValue || ""}?format=json`)
      if (!response.ok) throw new Error("Download failed")

      const data = await response.json()
      await this.#store(data)
      this.statusTarget.textContent = "Saved for offline"
    } catch (e) {
      this.statusTarget.textContent = "Download failed"
    }
  }

  async #store(data) {
    const db = await this.#openDB()
    const tx = db.transaction("passages", "readwrite")
    const store = tx.objectStore("passages")

    for (const item of data) {
      await store.put(item)
    }

    await new Promise((resolve, reject) => {
      tx.oncomplete = resolve
      tx.onerror = reject
    })
  }

  #openDB() {
    return new Promise((resolve, reject) => {
      const request = indexedDB.open("scriptures-offline", 1)
      request.onupgradeneeded = (e) => {
        const db = e.target.result
        if (!db.objectStoreNames.contains("passages")) {
          db.createObjectStore("passages", { keyPath: "id" })
        }
      }
      request.onsuccess = (e) => resolve(e.target.result)
      request.onerror = (e) => reject(e.target.error)
    })
  }
}
