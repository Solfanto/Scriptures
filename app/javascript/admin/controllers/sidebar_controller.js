import { Controller } from '@hotwired/stimulus'

// Connects to data-controller="sidebar"
export default class extends Controller {
  static targets = ['sidebar', 'overlay', 'toggle']

  connect () {
    // Optional: Add any initialization logic here
  }

  toggle () {
    this.sidebarTarget.classList.toggle('sidebar--open')
    this.overlayTarget.classList.toggle('mobile-overlay--visible')
    this.toggleTarget.classList.toggle('mobile-nav-toggle--open')
    this.toggleTarget.classList.toggle('mobile-nav-toggle--moved')
  }

  close () {
    this.sidebarTarget.classList.remove('sidebar--open')
    this.overlayTarget.classList.remove('mobile-overlay--visible')
    this.toggleTarget.classList.remove('mobile-nav-toggle--open')
    this.toggleTarget.classList.remove('mobile-nav-toggle--moved')
  }
}
