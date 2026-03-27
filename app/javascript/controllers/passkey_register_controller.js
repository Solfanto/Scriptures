import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  async register() {
    try {
      const optionsResponse = await fetch("/passkey_credentials/options_for_create", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "X-CSRF-Token": document.querySelector("meta[name='csrf-token']").content
        }
      })
      const options = await optionsResponse.json()

      options.challenge = this.#base64urlToBuffer(options.challenge)
      options.user.id = this.#base64urlToBuffer(options.user.id)
      if (options.excludeCredentials) {
        options.excludeCredentials = options.excludeCredentials.map(c => ({
          ...c, id: this.#base64urlToBuffer(c.id)
        }))
      }

      const credential = await navigator.credentials.create({ publicKey: options })

      const response = await fetch("/passkey_credentials", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "X-CSRF-Token": document.querySelector("meta[name='csrf-token']").content
        },
        body: JSON.stringify({
          credential: {
            id: credential.id,
            rawId: this.#bufferToBase64url(credential.rawId),
            type: credential.type,
            response: {
              attestationObject: this.#bufferToBase64url(credential.response.attestationObject),
              clientDataJSON: this.#bufferToBase64url(credential.response.clientDataJSON)
            }
          },
          label: "Passkey"
        })
      })

      if (response.ok) {
        window.location.reload()
      } else {
        const data = await response.json()
        alert(data.error || "Failed to register passkey")
      }
    } catch (e) {
      if (e.name !== "NotAllowedError") {
        console.error("Passkey registration failed:", e)
      }
    }
  }

  #base64urlToBuffer(base64url) {
    const base64 = base64url.replace(/-/g, "+").replace(/_/g, "/")
    const binary = atob(base64)
    const bytes = new Uint8Array(binary.length)
    for (let i = 0; i < binary.length; i++) bytes[i] = binary.charCodeAt(i)
    return bytes.buffer
  }

  #bufferToBase64url(buffer) {
    const bytes = new Uint8Array(buffer)
    let binary = ""
    for (const byte of bytes) binary += String.fromCharCode(byte)
    return btoa(binary).replace(/\+/g, "-").replace(/\//g, "_").replace(/=/g, "")
  }
}
