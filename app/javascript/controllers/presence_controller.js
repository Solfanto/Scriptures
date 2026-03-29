import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { groupId: Number }
  static targets = ["list"]

  #users = new Map()
  #subscription = null

  connect() {
    if (!this.hasGroupIdValue || !window.App?.cable) return

    this.#subscription = window.App.cable.subscriptions.create(
      { channel: "PresenceChannel", group_id: this.groupIdValue },
      {
        received: (data) => this.#handleMessage(data),
        connected: () => {},
        disconnected: () => {}
      }
    )
  }

  disconnect() {
    this.#subscription?.unsubscribe()
  }

  #handleMessage(data) {
    switch (data.type) {
      case "join":
        this.#users.set(data.user_id, { name: data.user })
        break
      case "leave":
        this.#users.delete(data.user_id)
        break
      case "reading":
        this.#users.set(data.user_id, { name: data.user, reading: data.passage_ref })
        break
    }
    this.#render()
  }

  #render() {
    if (this.#users.size === 0) {
      this.listTarget.innerHTML = '<p class="text-xs text-stone-400 italic">No one online</p>'
      return
    }

    const html = Array.from(this.#users.entries()).map(([, u]) => {
      const reading = u.reading ? `<span class="text-stone-400"> — ${u.reading}</span>` : ""
      return `<div class="flex items-center gap-2 text-xs">
        <div class="w-2 h-2 rounded-full bg-green-500 shrink-0"></div>
        <span class="text-stone-600 dark:text-stone-400">${u.name}${reading}</span>
      </div>`
    }).join("")

    this.listTarget.innerHTML = html
  }
}
